# Staging Layer

The staging layer provides cleaned, typed, and lightly transformed data from raw sources. This layer serves as the foundation for all downstream models and implements our first level of data quality checks.

## Purpose

- **1:1 relationship with source tables** - Each staging model corresponds to one raw table
- **Type casting and renaming** - Standardize column names and data types
- **Light transformations** - Timezone conversions, boolean flags, column renaming, coalesce logic
- **Data quality foundation** - Tests to catch issues early in the pipeline

## Models

| Model | Source | Grain | Description |
|-------|--------|-------|-------------|
| `stg_orders` | `raw.orders` | One row per order | Order header with status, delivery timestamps, and payment approval logic |
| `stg_customers` | `raw.customers` | One row per customer-order | Customer demographics and location (customer_id is unique per order, customer_unique_id spans orders) |
| `stg_order_items` | `raw.order_items` | One row per order line item | Product-level order details with price, freight, and surrogate key (`order_item_key`) |
| `stg_order_payments` | `raw.order_payments` | One row per payment transaction | Payment methods, installments, and values |
| `stg_order_reviews` | `raw.order_reviews` | One row per review | Customer ratings and comments |
| `stg_products` | `raw.products` | One row per product | Product catalog with physical dimensions |
| `stg_sellers` | `raw.sellers` | One row per seller | Seller information and location |
| `stg_geolocation` | `raw.geolocation` | One row per geolocation entry | Brazilian zip code coordinates (not yet deduplicated); enriched with state name and region from the `brazil_states_with_regions` seed |
| `stg_product_category_name` | `raw.product_category_name` | One row per category | Portuguese to English category translation; enriched with broad category from the `product_category_rollup` seed |

## Key Transformations

### Timezone Handling

All timestamp columns are provided in two versions using the custom `convert_to_timezone` macro:

**Original timestamps** (treated as Sao Paulo time, UTC-3):
- `order_purchase_timestamp`
- `order_payment_approved_at`
- `order_sent_to_carrier_date`
- `order_delivered_customer_date`
- `order_estimated_delivery_date`

**Eastern Time converted** (suffixed with `_et`):
- `order_purchase_timestamp_et`
- `order_payment_approved_at_et`
- `order_sent_to_carrier_date_et`
- `order_delivered_customer_date_et`
- `order_estimated_delivery_date_et`

**Implementation:** Uses custom `convert_to_timezone` macro located in `macros/timestamp_macros.sql`
```sql
-- Example usage
{{ convert_to_timezone('order_purchase_timestamp', 'America/New_York') }}
```

### Column Renaming

- `order_approved_at` renamed to `order_payment_approved_at` for clarity
- `order_delivered_carrier_date` renamed to `order_sent_to_carrier_date` for clarity
- `product_name_lenght` corrected to `product_name_length` (typo fix)
- `product_description_lenght` corrected to `product_description_length` (typo fix)

### Payment Approval Coalesce Logic

In `stg_orders`, missing `order_approved_at` values are backfilled for orders that reached post-approval statuses (approved, invoiced, processing, shipped, delivered) using `order_purchase_timestamp` as a proxy.

### Surrogate Keys

- `stg_order_items.order_item_key` - Generated via `dbt_utils.generate_surrogate_key(['order_id', 'order_item_id'])` to uniquely identify each order line item across the entire dataset

### Boolean Flags

- `stg_order_reviews.is_comment_present` - TRUE if review has a title or message

### Seed Data Joins

- `stg_product_category_name` joins the `product_category_rollup` seed on `product_category_name_english` to add `broad_category` (high-level category grouping like "Electronics & Tech", "Home & Living", etc.)
- `stg_geolocation` joins the `brazil_states_with_regions` seed on `geolocation_state` = `state_abbreviation` to add `geolocation_state_name` (full state name) and `geolocation_region` (North, Northeast, Central-West, Southeast, South)

## Data Quality

### Tests Implemented

Tests are defined in `staging.yml`:

**Uniqueness & Completeness (ERROR severity):**
- Primary keys tested with `unique` + `not_null`: `order_id`, `customer_id`, `product_id`, `seller_id`, `product_category_name`
- Foreign key not_null: `customer_id` on orders, `order_id` on items/payments/reviews, `product_id` and `seller_id` on items
- Critical field not_null: `order_purchase_timestamp`, `price`, `payment_type`, `payment_value`, `review_score`

**Referential Integrity (ERROR severity):**
- `stg_orders.customer_id` -> `stg_customers.customer_id`
- `stg_order_items.order_id` -> `stg_orders.order_id`
- `stg_order_items.product_id` -> `stg_products.product_id`
- `stg_order_items.seller_id` -> `stg_sellers.seller_id`
- `stg_order_payments.order_id` -> `stg_orders.order_id`
- `stg_order_reviews.order_id` -> `stg_orders.order_id`

**Accepted Values (WARN severity):**
- `order_status`: delivered, shipped, canceled, unavailable, invoiced, processing, created, approved
- `review_score`: 1, 2, 3, 4, 5

**Non-Negative Values:**
- `price`, `freight_value`, `payment_value`, `payment_installments`

### Custom Business Logic Tests

**Canceled Orders Data Quality Check:**

1. **Warning Test** (`warn_canceled_orders_with_delivery.sql`) - Identifies canceled orders with `order_delivered_customer_date` populated
2. **Error Test** (`error_excessive_canceled_with_delivery.sql`) - Alerts if >1% of canceled orders were delivered

**Findings:** Only 5 orders (~0.96%) are affected - likely data entry errors.

### Running Tests
```bash
# Run all staging tests
dbt test --select staging

# Run specific model tests
dbt test --select stg_orders

# Run custom business logic tests
dbt test --select warn_canceled_orders_with_delivery error_excessive_canceled_with_delivery
```

## Testing Philosophy

### Test Severity Strategy

**ERROR (Pipeline Blocking):**
- Primary key violations (duplicates, nulls)
- Foreign key violations (referential integrity)
- Critical business rule violations (e.g., >1% data quality issues)

**WARN (Non-Blocking Alerts):**
- Accepted values for enum fields (allows for new values)
- Known edge cases with low volume (<1% of records)
- Exploratory validations during development

## Naming Conventions

### Models
- Prefix: `stg_`
- Format: `stg_<entity_name>`
- Examples: `stg_orders`, `stg_customers`

### Columns
- Use `snake_case`
- Suffix timestamps with timezone: `_et`
- Boolean fields: `is_` or `has_` prefix
- Foreign keys: Match referenced table + `_id`

## Macros

### `convert_to_timezone(column_name, target_timezone)`
Converts naive timestamps to specified timezone.

**Location:** `macros/timestamp_macros.sql`

**Parameters:**
- `column_name` - Source timestamp column
- `target_timezone` - Target timezone (default: 'America/New_York')

**Example:**
```sql
{{ convert_to_timezone('order_purchase_timestamp') }} as order_purchase_timestamp_et
```

## Dependencies

### dbt Packages
- `dbt_utils` (1.1.1) - Testing utilities and helper macros

Install with:
```bash
dbt deps
```

## Known Data Quality Issues

### 1. Canceled Orders with Delivery Dates
- **Count:** 5 orders
- **Impact:** Minimal (<1% of canceled orders)
- **Root Cause:** Likely data entry errors or incorrect status classification
- **Mitigation:** Monitored via custom tests, does not block pipeline

### 2. Review Duplicates (Handled in Intermediate Layer)
- Some orders have multiple reviews
- Deduplication logic applied in `int_order_reviews`
- See `models/intermediate/README.md` for details

## Upstream Dependencies

All staging models depend on sources defined in `_sources.yml`:
```yaml
sources:
  - name: raw
    schema: raw
    tables:
      - name: orders
      - name: customers
      # ... etc
```

Additionally, 3 seed files are used to enrich staging models:
- `product_category_rollup`
- `brazil_states_with_regions`

## Downstream Usage

Staging models are consumed by:
- **Intermediate layer** - Business logic, enrichments, and aggregations
- **Marts layer** - Fact tables reference staging directly in some cases

**Recommendation:** Always reference staging models via `{{ ref('stg_model_name') }}` rather than querying raw tables directly.

## Maintenance

### Adding New Staging Models

1. Create SQL file: `models/staging/stg_<entity>.sql`
2. Add source definition in `_sources.yml`
3. Add model documentation and tests in `staging.yml`
4. Implement appropriate tests
5. Run `dbt run -s stg_<entity>` and `dbt test -s stg_<entity>`

### Updating Existing Models

1. Make changes to SQL file
2. Update documentation in `staging.yml`
3. Add/update tests as needed
4. Run affected models: `dbt run -s stg_<entity>+`
5. Verify downstream impact: `dbt test -s stg_<entity>+`

---

**Last Updated:** 2025-02-09  
**Maintained By:** Shreyeshi Somya