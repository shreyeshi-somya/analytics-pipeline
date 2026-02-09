# Intermediate Layer

The intermediate layer applies business logic, enrichments, and aggregations on top of staging models. These models join related entities, compute derived metrics, deduplicate data, and prepare reusable building blocks for the marts layer.

## Purpose

- **Data deduplication** - Deduplicate raw geolocation and review data to ensure clean 1:1 grains
- **Joins across staging models** - Combine related entities (e.g., products with category translations, customers/sellers with geolocation)
- **Business logic & derived metrics** - Delivery speed categories, payment breakdowns, shipping cost analysis, review sentiment
- **Aggregations** - Roll up payment transactions to the order level
- **Reusable building blocks** - Provide enriched entities that marts can reference without duplicating logic

## Models

### Data Deduplication

| Model | Grain | Description |
|-------|-------|-------------|
| `int_geolocation` | One row per zip code prefix | Deduplicated geolocation - selects most common lat/long per zip code; enriched with state name and region from the `brazil_states_with_regions` seed |

### Entity Enrichment

| Model | Grain | Description |
|-------|-------|-------------|
| `int_customers` | One row per `customer_id` (unique per order) | Customers enriched with geolocation coordinates, state name, and region via `int_geolocation`. Note: `customer_id` is unique per order, not per person - use `customer_unique_id` to identify the same customer across orders |
| `int_products` | One row per product | Products joined with English category name translations and broad category grouping from the `product_category_rollup` seed |
| `int_sellers` | One row per seller | Sellers enriched with geolocation coordinates, state name, and region via `int_geolocation` |

### Order Domain

| Model | Grain | Description |
|-------|-------|-------------|
| `int_order` | One row per order | Central order model joining orders with customer details, reviews, and payments; adds delivery flags, speed categories, review sentiment, customer state name, and customer region |
| `int_order_items` | One row per order line item | Order items enriched with order attributes, product dimensions, broad category, shipping weight calculations, seller location with coordinates, and geographic regions for both customer and seller |
| `int_order_reviews` | One row per order | Deduplicated reviews - consolidates multiple reviews per order into a single record |
| `int_order_payments__by_type` | One row per order + payment type | Payment transactions aggregated by payment type within each order |
| `int_order_payments` | One row per order | Order-level payment summary with breakdowns by payment method |

## Model Details

### int_geolocation

Deduplicates raw geolocation data which has multiple entries per zip code due to varying coordinate precision. Selects the most common lat/long pair for each zip code prefix using a count + rank approach.

**Sources:** `stg_geolocation`

**Deduplication logic:**
1. Groups by zip code prefix + lat/long/city/state, counting occurrences
2. Ranks by `row_count DESC` within each zip code prefix
3. Keeps only the top-ranked (most common) coordinate pair

**Key columns:**
- `geolocation_zip_code_prefix` - Unique zip code prefix (primary key after dedup)
- `geolocation_latitude`, `geolocation_longitude` - Most common coordinates
- `geolocation_city`, `geolocation_state` - City/state for the selected coordinates
- `geolocation_state_name` - Full state name (e.g., "São Paulo") from the `brazil_states_with_regions` seed
- `geolocation_region` - Geographic region (North, Northeast, Central-West, Southeast, South) from the `brazil_states_with_regions` seed

---

### int_customers

Enriches customer records with geographic coordinates by joining to deduplicated geolocation data on zip code prefix. The grain is one row per `customer_id`, which is unique per order - a single person placing multiple orders will have multiple `customer_id` values but share the same `customer_unique_id`.

**Sources:** `stg_customers`, `int_geolocation`

**Key columns:**
- `customer_id` - Unique identifier per order (not per person)
- `customer_unique_id` - Identifier that ties the same customer across multiple orders

**Key columns added:**
- `customer_geolocation_latitude`, `customer_geolocation_longitude` - Coordinates from geolocation lookup
- `customer_geolocation_city`, `customer_geolocation_state` - Geo-derived city/state for cross-referencing
- `customer_state_name` - Full state name from the `brazil_states_with_regions` seed (via `int_geolocation`)
- `customer_region` - Geographic region (North, Northeast, Central-West, Southeast, South) from the `brazil_states_with_regions` seed (via `int_geolocation`)

---

### int_products

Joins the product catalog with the category name translation table to provide English category names alongside Portuguese originals, and includes the broad category grouping from the `product_category_rollup` seed.

**Sources:** `stg_products`, `stg_product_category_name`

**Key columns added:**
- `product_category_name_english` - English translation of product category
- `broad_category` - High-level category grouping (e.g., "Electronics & Tech", "Home & Living") from the `product_category_rollup` seed (via `stg_product_category_name`)

---

### int_sellers

Enriches seller records with geographic coordinates by joining to deduplicated geolocation data on zip code prefix.

**Sources:** `stg_sellers`, `int_geolocation`

**Key columns added:**
- `seller_geolocation_latitude`, `seller_geolocation_longitude` - Coordinates from geolocation lookup
- `seller_geolocation_city`, `seller_geolocation_state` - Geo-derived city/state for cross-referencing
- `seller_state_name` - Full state name from the `brazil_states_with_regions` seed (via `int_geolocation`)
- `seller_region` - Geographic region (North, Northeast, Central-West, Southeast, South) from the `brazil_states_with_regions` seed (via `int_geolocation`)

---

### int_order_reviews

Handles the case where orders have multiple reviews. Consolidates review comments via `listagg()` and selects a single representative review per order.

**Sources:** `stg_order_reviews`

**Deduplication logic:**
1. Concatenates all review titles and messages for the order
2. Filters out reviews submitted more than 1 day after the first review (likely data errors)
3. Among remaining reviews, keeps the most recent one (`row_number()` by `review_answer_timestamp_et DESC`)

**Key columns:**
- `review_id`, `review_score` - From the selected representative review
- `review_comment_title`, `review_comment_message` - Concatenated across all reviews for the order
- `is_comment_present` - Whether any review had a comment
- `review_creation_date_et`, `review_answer_timestamp_et` - Timestamps in Eastern Time

---

### int_order_payments__by_type

Aggregates raw payment transactions to one row per order + payment type combination. An order paid with both credit card and voucher produces two rows.

**Sources:** `stg_order_payments`

**Key columns:**
- `payment_value` - Total value for this payment type on the order
- `payment_installments` - Total installments for this payment type
- `avg_installment_value` - Average installment amount
- `transaction_count` - Number of individual transactions for this type
- `is_first_payment_type` - Whether this was the first payment method used

---

### int_order_payments

Rolls up `int_order_payments__by_type` to a single row per order, providing a complete payment summary.

**Sources:** `int_order_payments__by_type`

**Key columns:**
- `total_payment_value` - Total amount paid across all methods
- `total_payment_installments`, `avg_installment_value` - Installment summary
- `payment_type_count` - Number of distinct payment methods used
- `first_payment_type` - First payment method by sequence
- `primary_payment_type` - Payment method with highest value (ranked by `payment_value DESC`)
- `voucher_payment_value`, `credit_card_payment_value`, `debit_card_payment_value`, `boleto_payment_value` - Value breakdown by type
- `used_voucher`, `used_credit_card`, `used_debit_card`, `used_boleto` - Boolean flags per method
- `used_multiple_payment_methods` - Split payment flag
- `used_installments` - Whether more than 1 installment was used
- `primary_payment_category` - Simplified grouping: card, boleto, voucher, other
- `is_high_installment_count` - Flag for orders with >6 installments

---

### int_order_items

Enriches order line items with order-level attributes, product details, shipping logistics calculations, and seller location with coordinates.

**Sources:** `stg_order_items`, `int_order`, `int_products`, `int_sellers`

**Key columns added:**

*Order Attributes (from `int_order`):*
- `customer_unique_id`, `order_status`, `order_purchase_timestamp_et`, `order_delivered_customer_date_et`
- `is_delivered`, `is_in_progress`, `is_canceled`, `is_delivered_on_time`
- `days_to_delivery`, `delivery_speed_category`
- `customer_city`, `customer_state`, `customer_state_name`, `customer_region`
- `review_score`, `review_sentiment`, `has_review`
- `total_payment_value`, `total_payment_installments`

*Financial:*
- `total_item_value` - Price + freight for the line item
- `freight_pct_of_price` - Shipping cost as a percentage of product price

*Shipping & Logistics:*
- `product_volume_cm3` - Product volume (L x W x H)
- `volumetric_weight_kg` - Shipping industry standard: volume / 6000
- `chargeable_weight_kg` - Greater of actual weight vs volumetric weight
- `freight_per_kg` - Freight cost per chargeable kg
- `product_size_category` - small / medium / large / extra_large (based on volume)
- `is_heavy_item` - Flag for products >5kg

*Product Attributes (from `int_products`):*
- `product_category_name_english` - English category name
- `broad_category` - High-level category grouping (e.g., "Electronics & Tech", "Home & Living")
- `product_name_length`, `product_description_length` - Listing quality metrics
- `is_high_value_item` - Flag for items >$100
- `has_photos`, `has_detailed_description` - Product listing quality flags

*Seller (from `int_sellers`):*
- `seller_city`, `seller_state`, `seller_zip_code_prefix` - Seller location
- `seller_geolocation_latitude`, `seller_geolocation_longitude` - Seller coordinates
- `seller_state_name`, `seller_region` - Full state name and geographic region

---

### int_order

The central order-level model that brings together orders, customer details, reviews, and payments into a single wide table.

**Sources:** `stg_orders`, `int_customers`, `int_order_reviews`, `int_order_payments`

**Key columns added:**

*Order Flags:*
- `is_delivered` - Order was delivered (not canceled, has delivery date)
- `is_canceled` - Order status is canceled
- `is_delivered_on_time` - Delivered before or on estimated date
- `is_in_progress` - Order is in an active fulfillment status

*Delivery Metrics:*
- `days_from_purchase_to_sent_to_carrier` - Seller fulfillment speed
- `days_in_transit` - Carrier transit time
- `days_to_delivery` - Total days from purchase to delivery
- `days_late` - Days past estimated delivery date
- `delivery_speed_category` - express / fast / standard / slow / very_slow

*Customer Fields (from `int_customers`):*
- `customer_unique_id` - Unique customer identifier across all orders
- `customer_zip_code_prefix`, `customer_city`, `customer_state` - Customer location
- `customer_state_name`, `customer_region` - Full state name and geographic region
- `customer_geolocation_latitude`, `customer_geolocation_longitude` - Customer coordinates

*Review Fields (from `int_order_reviews`):*
- All fields from `int_order_reviews`
- `review_sentiment` - positive (4-5), neutral (3), negative (1-2)
- `has_review` - Whether the order has a review
- `days_to_review` - Days from delivery to review
- `is_quick_review` - Review submitted within 3 days of delivery

*Payment Fields (from `int_order_payments`):*
- All fields from `int_order_payments`
- `is_payment_details_missing` - Payment was approved but no payment detail records exist

## DAG (Dependency Graph)

```
stg_geolocation ────────┐
brazil_states_with_     │
  regions (seed) ───────┤
                        ├──▶ int_geolocation ──────┐
                        │                          │
stg_customers ──────────┤                          │
                        ├──▶ int_customers ◀───────┤
                        │         │                │
stg_sellers ────────────┤         │                │
                        ├──▶ int_sellers ◀─────────┘
                        │         │
stg_products ───────────┤         │
stg_product_category ───┤         │
  (joins product_       │         │
   category_rollup      │         │
   seed)                │         │
                        ├──▶ int_products ─────┐
                        │                      │
stg_order_reviews ──────┤                      │
                        ├──▶ int_order_reviews ─────┐
                        │                           │
stg_order_payments ─────┤                           │
                        ├──▶ int_order_payments     │
                              __by_type             │
                                │                   │
                                ▼                   │
                        int_order_payments ─────────┤
                                                    │
stg_orders ─────────────────────────────────────────┤
int_customers ──────────────────────────────────────┤
                                                    │
                                                    ▼
                                              int_order
                                                    │
stg_order_items ────────────────────────────────────┤
int_products ───────────────────────────────────────┤
int_sellers ────────────────────────────────────────┤
                                                    │
                                                    ▼
                                          int_order_items
```

## Naming Conventions

### Models
- Prefix: `int_`
- Format: `int_<entity_name>`
- Double underscore for further specificity: `int_order_payments__by_type`

### Columns
- Use `snake_case`
- Timestamps suffixed with timezone: `_et`
- Boolean fields: `is_`, `has_`, `used_` prefix
- Aggregations named descriptively: `total_payment_value`, `avg_installment_value`
- Categories suffixed with `_category`: `delivery_speed_category`, `product_size_category`

## Materialization

All intermediate models are materialized as **tables** in the `intermediate` schema:

```sql
{{ config(materialized='table', schema='intermediate') }}
```

## Downstream Usage

Intermediate models are consumed by:
- **Marts layer** - Dimension tables, fact tables, and denormalized marts
- **Ad-hoc analysis** - Direct querying for exploration

**Recommendation:** Reference intermediate models via `{{ ref('int_model_name') }}` in downstream models.

## Maintenance

### Adding New Intermediate Models

1. Create SQL file: `models/intermediate/int_<entity>.sql`
2. Include the config block with `materialized='table'` and `schema='intermediate'`
3. Add model documentation and tests in `intermediate.yml`
4. Run `dbt run -s int_<entity>` and `dbt test -s int_<entity>`

### Updating Existing Models

1. Make changes to SQL file
2. Update documentation as needed
3. Run affected models: `dbt run -s int_<entity>+`
4. Verify downstream impact: `dbt test -s int_<entity>+`

---

**Last Updated:** 2025-02-07  
**Maintained By:** Shreyeshi Somya
