{{
    config(
        materialized = 'table',
        schema = 'core'
    )
}}

select
    -- Order Item Details
    order_id
    , order_item_id
    , order_item_key
    , product_id
    , seller_id
    , shipping_limit_date_et
    , price
    , freight_value
    , total_item_value
    , freight_pct_of_price

    -- Order Attributes
    , customer_unique_id
    , order_status
    , is_delivered
    , is_in_progress
    , is_canceled
    , order_purchase_timestamp_et
    , order_delivered_customer_date_et
    , is_delivered_on_time
    , days_to_delivery
    , delivery_speed_category
    , customer_city
    , customer_state
    , review_score
    , review_sentiment
    , has_review
    , total_payment_value
    , total_payment_installments

    , case when is_delivered then total_item_value else 0 end as revenue_delivered
    , case when is_delivered then price else 0 end as product_price_delivered
    , case when is_delivered then freight_value else 0 end as freight_delivered

    -- Product Attributes
    , product_name_length
    , product_description_length
    , product_category_name
    , product_category_name_english
    , product_weight_g
    , product_length_cm
    , product_height_cm
    , product_width_cm
    , product_volume_cm3
    , volumetric_weight_kg
    , chargeable_weight_kg
    , freight_per_kg
    , product_size_category
    , is_heavy_item
    , is_high_value_item
    , has_photos
    , has_detailed_description

    -- Seller Info
    , seller_city
    , seller_state
    , seller_zip_code_prefix
    , seller_geolocation_latitude
    , seller_geolocation_longitude

    

from {{ ref('int_order_items') }}
