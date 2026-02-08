{{
    config(
        materialized = 'table',
        schema = 'core'
    )
}}

select
    product_id
    
    -- Product attributes
    , product_category_name
    , product_category_name_english
    , product_weight_g
    , product_length_cm
    , product_height_cm
    , product_width_cm
    , product_volume_cm3
    , volumetric_weight_kg
    , chargeable_weight_kg
    , product_size_category
    , is_heavy_item
    , has_photos
    , has_detailed_description
    
    -- Sales metrics (delivered orders only)
    , count(distinct case when is_delivered then order_id end) as total_orders
    , count(distinct case when is_delivered then order_item_key end) as total_units_sold
    
    -- Revenue metrics (delivered orders only)
    , sum(case when is_delivered then price end) as total_revenue
    , sum(case when is_delivered then freight_value end) as total_freight
    , sum(case when is_delivered then total_item_value end) as total_value
    
    , avg(case when is_delivered then price end) as avg_price
    , avg(case when is_delivered then freight_value end) as avg_freight
    
    -- Customer satisfaction
    , avg(case when has_review then review_score end) as avg_review_score
    , count(case when has_review then order_id end) as reviewed_orders
    , count(case when review_sentiment = 'positive' then order_id end)::float / reviewed_orders as positive_review_rate
    
    -- Delivery performance
    , avg(case when is_delivered then days_to_delivery end) as avg_delivery_days
    
    -- Seller metrics
    , count(distinct seller_id) as unique_sellers
    -- Dates
    , min(case when is_delivered then order_purchase_timestamp_et end) as first_sale_date
    , max(case when is_delivered then order_purchase_timestamp_et end) as last_sale_date

from {{ ref('int_order_items') }}
{{ dbt_utils.group_by(14) }}