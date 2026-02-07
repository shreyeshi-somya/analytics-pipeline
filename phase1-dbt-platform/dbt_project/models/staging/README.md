# Staging Layer

The staging layer provides cleaned, typed, and lightly transformed data from raw sources. This layer serves as the foundation for all downstream models and implements our first level of data quality checks.

## Purpose

- **1:1 relationship with source tables** - Each staging model corresponds to one raw table
- **Type casting and renaming** - Standardize column names and data types
- **Light transformations** - Timezone conversions, boolean flags, basic calculations
- **Data quality foundation** - Tests to catch issues early in the pipeline

## Models

### Core Tables

| Model | Source | Grain | Description |
|-------|--------|-------|-------------|
| `stg_orders` | `raw.orders` | One row per order | Order header with delivery timestamps and status |
| `stg_customers` | `raw.customers` | One row per customer | Customer demographics and location |
| `stg_order_items` | `raw.order_items` | One row per order line item | Product-level order details |
| `stg_order_payments` | `raw.order_payments` | One row per payment transaction | Payment methods and values |
| `stg_order_reviews` | `raw.order_reviews` | One row per review | Customer ratings and comments |
| `stg_products` | `raw.products` | One row per product | Product catalog with dimensions |
| `stg_sellers` | `raw.sellers` | One row per seller | Seller information and location |
| `stg_product_category_name` | `raw.product_category_name` | One row per category | Portuguese to English category translation |

## Key Transformations

### Timezone Handling

All timestamp columns are provided in two versions:

**Original timestamps** (treated as São Paulo time, UTC-3):
- `order_purchase_timestamp`
- `order_approved_at`
- `order_delivered_carrier_date`
- `order_delivered_customer_date`
- `order_estimated_delivery_date`

**Eastern Time converted** (for US-based analysis):
- `order_purchase_timestamp_et`
- `order_approved_at_et`
- `order_delivered_carrier_date_et`
- `order_delivered_customer_date_et`
- `order_estimated_delivery_date_et`

**Implementation:** Uses custom `convert_to_timezone` macro located in `macros/timestamp_macros.sql`
```sql
-- Example usage
{{ convert_to_timezone('order_purchase_timestamp', 'America/New_York') }}
```

### Boolean Flags

Added boolean flags for easier filtering where appropriate

**stg_order_reviews:**
- `is_comment_present` - TRUE if review has title or message

## Data Quality

### Tests Implemented

#### Column-level Tests

**Uniqueness & Completeness:**
- **Uniqueness:** Primary keys tested with `unique` constraint (ERROR severity)
- **Not Null:** Critical fields validated for completeness (ERROR severity)
- **Referential Integrity:** Foreign key relationships verified (ERROR severity)

**Accepted Values:**
- **Enumerations:** Checked against expected valid options (WARN severity)
- **Rationale:** Set to WARN rather than ERROR to allow for:
  - New status values added in source system
  - Edge cases or experimental features
- **Example:** `order_status` accepts: delivered, shipped, canceled, unavailable, invoiced, processing, created, approved

**Configuration:**
```yaml
# In staging.yml
- name: order_status
  tests:
    - accepted_values:
        values: ['delivered', 'shipped', 'canceled', ...]
        config:
          severity: warn  # Alerts but doesn't fail pipeline
```

#### Custom Business Logic Tests

**Canceled Orders Data Quality Check**

Two-tiered approach to monitor data quality:

1. **Warning Test** (`warn_canceled_orders_with_delivery.sql`)
   - Identifies canceled orders that have `order_delivered_customer_date` populated
   - Severity: WARN
   - Purpose: Document edge cases for investigation
   
2. **Error Test** (`error_excessive_canceled_with_delivery.sql`)
   - Alerts if >1% of canceled orders were delivered to customers
   - Severity: ERROR
   - Purpose: Catch systematic data quality degradation

**Findings:**
- Only **5 orders** (~0.96% of canceled orders) have customer delivery dates
- These likely represent:
  - Data entry errors
  - Edge cases

**Business Rule Rationale:**
- ✅ **Acceptable:** Order canceled after handed to carrier (still in transit)
  - Has `order_delivered_carrier_date` but no `order_delivered_customer_date`
- ❌ **Suspicious:** Order canceled after customer delivery
  - Has `order_delivered_customer_date` populated
  - Should investigate or recategorize as "return"

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

We use a tiered approach to test severity:

**ERROR (Pipeline Blocking):**
- Primary key violations (duplicates, nulls)
- Foreign key violations (referential integrity)
- Critical business rule violations (e.g., >1% data quality issues)
- Data that would cause downstream model failures

**WARN (Non-Blocking Alerts):**
- Accepted values for enum fields (allows for new values)
- Known edge cases with low volume (<1% of records)
- Data quality issues that don't impact core metrics
- Exploratory validations during development

**Rationale:**
- Prevents false positives from blocking production
- Allows source system evolution (new statuses, categories)
- Documents data quality issues without halting analysis
- Enables iterative improvement of data quality rules

## Naming Conventions

### Models
- Prefix: `stg_`
- Format: `stg_<entity_name>`
- Examples: `stg_orders`, `stg_customers`

### Columns
- Use `snake_case`
- Suffix timestamps with timezone: `_utc`, `_et`
- Boolean fields: `is_` or `has_` or `used_` prefix
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
{{ convert_to_timezone('order_purchase_timestamp', 'America/Sao_Paulo') }} as order_purchase_timestamp_br
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
- **Mitigation:** 
  - Monitored via custom tests
  - Flagged for manual review
  - Does not block pipeline (WARN severity)

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

## Downstream Usage

Staging models are consumed by:
- **Intermediate layer** - Business logic and aggregations
- **Marts layer** - Final dimensional models
- **Ad-hoc analysis** - Direct querying for exploration

**Recommendation:** Always reference staging models via `{{ ref('stg_model_name') }}` rather than querying raw tables directly.

## Maintenance

### Adding New Staging Models

1. Create SQL file: `models/staging/stg_<entity>.sql`
2. Add source definition in `_sources.yml`
3. Add model documentation in `staging.yml`
4. Implement appropriate tests
5. Run `dbt run -s stg_<entity>` and `dbt test -s stg_<entity>`

### Updating Existing Models

1. Make changes to SQL file
2. Update documentation in `staging.yml`
3. Add/update tests as needed
4. Run affected models: `dbt run -s stg_<entity>+`
5. Verify downstream impact: `dbt test -s stg_<entity>+`

## Questions or Issues?

For questions about staging models, data quality issues, or transformation logic, please:
1. Check this README
2. Review model SQL and tests
3. Consult team data documentation
4. Open an issue in the repository

---

**Last Updated:** [Current Date]  
**Maintained By:** [Shreyeshi Somya]