-- ============================================================================
-- mart_order_items
-- Denormalized order item model for Data Visualization tool
-- Combines fact_order_items with dimension attributes from dim_customers,
-- dim_sellers, and dim_products for self-serve analytics and dashboarding.
-- ============================================================================

{{
    config(
        materialized = 'table',
        schema = 'mart'
    )
}}

select
    -- ========================================================================
    -- Fact: Order Item Details
    -- ========================================================================
    fact.order_id
    , fact.order_item_id
    , fact.order_item_key
    , fact.product_id
    , fact.seller_id
    , fact.shipping_limit_date_et
    , fact.price
    , fact.freight_value
    , fact.total_item_value
    , fact.freight_pct_of_price

    -- Order Attributes
    , fact.customer_unique_id
    , fact.order_status
    , fact.is_delivered
    , fact.is_in_progress
    , fact.is_canceled
    , fact.order_purchase_timestamp_et
    , fact.order_delivered_customer_date_et
    , fact.order_estimated_delivery_date_et
    , fact.is_delivered_on_time
    , fact.days_to_delivery
    , fact.delivery_speed_category
    , fact.customer_city
    , fact.customer_state
    , fact.customer_state_name
    , fact.customer_region
    , fact.review_score
    , fact.review_sentiment
    , fact.has_review
    , fact.total_payment_value
    , fact.total_payment_installments
    , fact.revenue_delivered
    , fact.product_price_delivered
    , fact.freight_delivered

    -- Product Attributes
    , fact.product_name_length
    , fact.product_description_length
    , fact.product_category_name
    , fact.product_category_name_english
    , fact.broad_category
    , fact.product_weight_g
    , fact.product_length_cm
    , fact.product_height_cm
    , fact.product_width_cm
    , fact.product_volume_cm3
    , fact.volumetric_weight_kg
    , fact.chargeable_weight_kg
    , fact.freight_per_kg
    , fact.product_size_category
    , fact.is_heavy_item
    , fact.is_high_value_item
    , fact.has_photos
    , fact.has_detailed_description

    -- Seller Info
    , fact.seller_city
    , fact.seller_state
    , fact.seller_zip_code_prefix
    , fact.seller_geolocation_latitude
    , fact.seller_geolocation_longitude
    , fact.seller_state_name
    , fact.seller_region

    -- ========================================================================
    -- Dimension: Customer Aggregated Metrics (from dim_customers)
    -- ========================================================================
    , dim_cust.customer_zip_code_prefix as customer_zip_code_prefix
    , dim_cust.customer_geolocation_latitude as customer_geolocation_latitude
    , dim_cust.customer_geolocation_longitude as customer_geolocation_longitude
    , dim_cust.total_orders_all_statuses as customer_total_orders
    , dim_cust.total_delivered_orders as customer_total_delivered_orders
    , dim_cust.in_progress_orders as customer_in_progress_orders
    , dim_cust.canceled_orders as customer_canceled_orders
    , dim_cust.cancellation_rate as customer_cancellation_rate
    , dim_cust.has_repeat_orders as customer_has_repeat_orders
    , dim_cust.lifetime_value as customer_lifetime_value
    , dim_cust.first_order_date as customer_first_order_date
    , dim_cust.last_order_date as customer_last_order_date
    , dim_cust.customer_lifetime_days
    , dim_cust.avg_days_between_orders as customer_avg_days_between_orders
    , dim_cust.pct_orders_paid_with_voucher as customer_pct_orders_paid_with_voucher
    , dim_cust.pct_orders_paid_with_credit_card as customer_pct_orders_paid_with_credit_card
    , dim_cust.dominant_payment_type as customer_dominant_payment_type
    , dim_cust.avg_review_score as customer_avg_review_score
    , dim_cust.reviewed_orders as customer_reviewed_orders
    , dim_cust.review_rate as customer_review_rate

    -- ========================================================================
    -- Dimension: Seller Aggregated Metrics (from dim_sellers)
    -- ========================================================================
    , dim_sell.total_orders_all_statuses as seller_total_orders
    , dim_sell.total_delivered_orders as seller_total_delivered_orders
    , dim_sell.has_repeat_orders as seller_has_repeat_orders
    , dim_sell.in_progress_orders as seller_in_progress_orders
    , dim_sell.canceled_orders as seller_canceled_orders
    , dim_sell.cancellation_rate as seller_cancellation_rate
    , dim_sell.total_items_sold as seller_total_items_sold
    , dim_sell.unique_products_sold as seller_unique_products_sold
    , dim_sell.unique_categories_sold as seller_unique_categories_sold
    , dim_sell.avg_item_price as seller_avg_item_price
    , dim_sell.avg_freight_per_item as seller_avg_freight_per_item
    , dim_sell.total_product_revenue as seller_total_product_revenue
    , dim_sell.total_freight_collected as seller_total_freight_collected
    , dim_sell.total_order_value as seller_total_order_value
    , dim_sell.lifetime_value as seller_lifetime_value
    , dim_sell.avg_delivery_days as seller_avg_delivery_days
    , dim_sell.on_time_delivery_rate as seller_on_time_delivery_rate
    , dim_sell.avg_review_score as seller_avg_review_score
    , dim_sell.reviewed_orders as seller_reviewed_orders
    , dim_sell.positive_review_rate as seller_positive_review_rate
    , dim_sell.first_sale_date as seller_first_sale_date
    , dim_sell.last_sale_date as seller_last_sale_date
    , dim_sell.seller_tenure_days

    -- ========================================================================
    -- Dimension: Product Aggregated Metrics (from dim_products)
    -- ========================================================================
    , dim_prod.broad_category as product_broad_category
    , dim_prod.total_orders as product_total_orders
    , dim_prod.total_units_sold as product_total_units_sold
    , dim_prod.total_revenue as product_total_revenue
    , dim_prod.total_freight as product_total_freight
    , dim_prod.total_value as product_total_value
    , dim_prod.avg_price as product_avg_price
    , dim_prod.avg_freight as product_avg_freight
    , dim_prod.avg_review_score as product_avg_review_score
    , dim_prod.reviewed_orders as product_reviewed_orders
    , dim_prod.positive_review_rate as product_positive_review_rate
    , dim_prod.avg_delivery_days as product_avg_delivery_days
    , dim_prod.unique_sellers as product_unique_sellers
    , dim_prod.first_sale_date as product_first_sale_date
    , dim_prod.last_sale_date as product_last_sale_date

from {{ ref('fact_order_items') }} fact
left join {{ ref('dim_customers') }} dim_cust on fact.customer_unique_id = dim_cust.customer_unique_id
left join {{ ref('dim_sellers') }} dim_sell on fact.seller_id = dim_sell.seller_id
left join {{ ref('dim_products') }} dim_prod on fact.product_id = dim_prod.product_id