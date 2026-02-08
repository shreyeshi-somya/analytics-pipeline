# Mart Layer

The mart layer is the final consumption layer of the dbt project. It contains dimension tables, fact tables, and denormalized mart tables optimized for analytics and visualization tools.

## Purpose

- **Dimension tables** - Aggregated entity profiles (customers, sellers, products) with lifetime metrics
- **Fact tables** - Transactional grain tables enriched with business context (holiday flags, seed data joins)
- **Denormalized marts** - Wide tables joining facts with dimensions for self-serve analytics in visualization tools

## Folder Structure

```
models/mart/
├── mart.yml                  # Tests and documentation for all mart models
├── README.md
├── Dimensions/
│   ├── dim_customers.sql     # Customer dimension
│   ├── dim_sellers.sql       # Seller dimension
│   └── dim_products.sql      # Product dimension
├── Facts/
│   ├── fact_order.sql        # Order-level fact
│   └── fact_order_items.sql  # Order line item fact
└── mart_order_items.sql      # Denormalized mart for visualization
```

## Models

### Dimensions

| Model | Grain | Source | Description |
|-------|-------|--------|-------------|
| `dim_customers` | One row per `customer_unique_id` | `int_order` | Customer profiles with most recent address, order counts, lifetime value, payment behavior, and review metrics |
| `dim_sellers` | One row per `seller_id` | `int_order_items` | Seller profiles with location, sales volume, revenue, delivery performance, and review metrics |
| `dim_products` | One row per `product_id` | `int_order_items` | Product catalog with physical attributes, sales metrics, revenue, and customer satisfaction |

### Facts

| Model | Grain | Source | Description |
|-------|-------|--------|-------------|
| `fact_order` | One row per `order_id` | `int_order` + `brazilian_holidays` seed | Complete order record with delivery metrics, customer details, review sentiment, full payment breakdown, and holiday flags |
| `fact_order_items` | One row per order line item | `int_order_items` | Order line items with order attributes, product dimensions, shipping logistics, and seller location |

### Denormalized Marts

| Model | Grain | Source | Description |
|-------|-------|--------|-------------|
| `mart_order_items` | One row per order line item | `fact_order_items` + all dimensions | Wide table joining fact with dim_customers, dim_sellers, and dim_products for Data Visualization tool |

## Model Details

### dim_customers

Aggregates order-level data from `int_order` to the `customer_unique_id` grain. Uses `max_by()` to capture the most recent address.

**Key metrics:**
- *Order Activity:* `total_orders_all_statuses`, `total_delivered_orders`, `canceled_orders`, `cancellation_rate`, `has_repeat_orders`
- *Value:* `lifetime_value` (sum of delivered order payments), `first_order_date`, `last_order_date`, `customer_lifetime_days`
- *Payment Behavior:* `pct_orders_paid_with_voucher`, `pct_orders_paid_with_credit_card`, `dominant_payment_type`
- *Review:* `avg_review_score`, `reviewed_orders`, `review_rate`

---

### dim_sellers

Aggregates order item data from `int_order_items` to the `seller_id` grain. Includes seller location attributes as group-by columns.

**Key metrics:**
- *Order Activity:* `total_orders_all_statuses`, `total_delivered_orders`, `canceled_orders`, `cancellation_rate`
- *Sales Volume:* `total_items_sold`, `unique_products_sold`, `unique_categories_sold`
- *Revenue:* `total_product_revenue`, `total_freight_collected`, `total_order_value`, `lifetime_value`
- *Performance:* `avg_delivery_days`, `on_time_delivery_rate`, `avg_review_score`, `positive_review_rate`
- *Tenure:* `first_sale_date`, `last_sale_date`, `seller_tenure_days`

---

### dim_products

Aggregates order item data from `int_order_items` to the `product_id` grain. Includes physical product attributes as group-by columns.

**Key metrics:**
- *Sales:* `total_orders`, `total_units_sold`, `unique_sellers`
- *Revenue:* `total_revenue`, `total_freight`, `total_value`, `avg_price`, `avg_freight`
- *Satisfaction:* `avg_review_score`, `reviewed_orders`, `positive_review_rate`
- *Delivery:* `avg_delivery_days`
- *Timeline:* `first_sale_date`, `last_sale_date`

---

### fact_order

Selects all columns from `int_order` and joins to the `brazilian_holidays` seed on purchase date to add holiday context.

**Sources:** `int_order`, `brazilian_holidays` (seed)

**Join:** `date(order_purchase_timestamp_et) = date(holiday_date)`

**Columns added from seed:**
- `holiday_name` - Name of the holiday (null if not a holiday)
- `is_national_holiday` - Whether it's a national holiday
- `holiday_type` - public, religious, or cultural
- `is_holiday_order` - Boolean flag for orders placed on a holiday

---

### fact_order_items

Selects all columns from `int_order_items` as a pass-through to the mart layer.

**Sources:** `int_order_items`

---

### mart_order_items

Denormalized wide table purpose-built for the Data Visualization tool. Joins `fact_order_items` with all three dimensions so analysts can slice and dice without writing joins.

**Sources:** `fact_order_items`, `dim_customers`, `dim_sellers`, `dim_products`

**Joins:**
- `dim_customers` on `customer_unique_id` — adds customer lifetime metrics
- `dim_sellers` on `seller_id` — adds seller performance metrics
- `dim_products` on `product_id` — adds product sales metrics

All dimension columns are prefixed with `customer_`, `seller_`, or `product_` to avoid ambiguity.

## DAG (Dependency Graph)

```
                                 ┌──▶ dim_customers ──────────┐
                                 │                            │
int_order ──────────┬────────────┤                            │
                    │            │                            │
                    ▼            │                            │
brazilian_holidays ─┤            │                            │
                    ├──▶ fact_order                           │
                                                              │
                                 ┌──▶ dim_sellers ────────────┤
                                 │                            │
int_order_items ────┬────────────┤                            │
                    │            │                            │
                    │            ├──▶ dim_products ───────────┤
                    │            │                            │
                    ▼            │                            ▼
              fact_order_items ──┴──────────────────▶ mart_order_items
```

## Materialization

All mart models are materialized as **tables**:

- Dimensions and facts use `schema = 'core'`
- Denormalized marts use `schema = 'mart'`

```sql
-- Dimensions & Facts
{{ config(materialized='table', schema='core') }}

-- Denormalized Marts
{{ config(materialized='table', schema='mart') }}
```

## Naming Conventions

### Models
- Dimensions: `dim_<entity>` (e.g., `dim_customers`, `dim_sellers`)
- Facts: `fact_<entity>` (e.g., `fact_order`, `fact_order_items`)
- Denormalized marts: `mart_<purpose>` (e.g., `mart_order_items`)

### Columns
- Dimension metrics are prefixed when joined into marts: `customer_lifetime_value`, `seller_avg_review_score`, `product_total_revenue`
- Use `snake_case`
- Boolean fields: `is_`, `has_`, `used_` prefix
- Rates and ratios suffixed descriptively: `cancellation_rate`, `on_time_delivery_rate`

## Downstream Usage

Mart models are consumed by:
- **Data Visualization tools** - Dashboards and reports (primarily `mart_order_items`)
- **Ad-hoc analysis** - Direct querying of facts and dimensions
- **Reporting** - Scheduled reports and metrics

## Maintenance

### Adding New Mart Models

1. Create SQL file in the appropriate subfolder (`Dimensions/`, `Facts/`, or root for marts)
2. Include the config block with appropriate schema
3. Add model documentation and tests in `mart.yml`
4. Run `dbt run -s <model_name>` and `dbt test -s <model_name>`

### Updating Existing Models

1. Make changes to SQL file
2. Update documentation in `mart.yml`
3. Run affected models: `dbt run -s <model_name>`
4. Verify with: `dbt test -s <model_name>`

---

**Last Updated:** 2025-02-07  
**Maintained By:** Shreyeshi Somya
