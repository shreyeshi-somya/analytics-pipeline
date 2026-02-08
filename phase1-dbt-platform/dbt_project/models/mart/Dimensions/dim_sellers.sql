{{
    config(
        materialized = 'table',
        schema = 'core'
    )
}}

select
    seller_id
    , seller_city
    , seller_state
    , seller_zip_code_prefix
    , seller_geolocation_latitude
    , seller_geolocation_longitude

    -- Aggregated metrics
    -- Order Metrics
    , count(distinct order_id) as total_orders_all_statuses
    , count(distinct case when is_delivered then order_id else null end) as total_delivered_orders
    , total_delivered_orders > 1 as has_repeat_orders
    , count(distinct case when is_in_progress then order_id else null end) as in_progress_orders
    , count(distinct case when is_canceled then order_id else null end) as canceled_orders
    , canceled_orders::float/total_orders_all_statuses as cancellation_rate

    -- Order - Item Metrics
    , count(distinct case when is_delivered then order_item_key end) as total_items_sold
    -- Product metrics
    , count(distinct product_id) as unique_products_sold
    , count(distinct product_category_name_english) as unique_categories_sold
    , avg(case when is_delivered then price end) as avg_item_price
    , avg(case when is_delivered then freight_value end) as avg_freight_per_item
    
    -- Revenue metrics (delivered only)
    , sum(case when is_delivered then price end) as total_product_revenue
    , sum(case when is_delivered then freight_value end) as total_freight_collected
    , sum(case when is_delivered then total_item_value end) as total_order_value
    , sum(case when is_delivered then total_payment_value else 0 end) as lifetime_value
    
    -- Delivery performance
    , avg(case when is_delivered then days_to_delivery end) as avg_delivery_days
    , count(case when is_delivered and is_delivered_on_time then order_id end)::float/total_delivered_orders as on_time_delivery_rate
    
    -- Reviews - Customer satisfaction
    , avg(case when has_review then review_score end) as avg_review_score
    , count(case when has_review then order_id end) as reviewed_orders
    , count(case when review_sentiment = 'positive' then order_id end)::float/ reviewed_orders as positive_review_rate

    -- Dates
    , min(case when is_delivered then order_purchase_timestamp_et end) as first_sale_date
    , max(case when is_delivered then order_purchase_timestamp_et end) as last_sale_date
    -- Seller activity
    , date_diff('day', first_sale_date, last_sale_date) as seller_tenure_days

from {{ ref('int_order_items') }}
{{ dbt_utils.group_by(6) }}