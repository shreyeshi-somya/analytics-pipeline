{{
    config(
        materialized = 'table',
        schema = 'intermediate'
    )
}}

select
    
    order_items.order_id
    , order_items.order_item_id
    , order_items.order_item_key
    , order_items.product_id
    , order_items.seller_id
    , order_items.shipping_limit_date_et
    , order_items.price
    , order_items.freight_value
    -- Total cost to customer (product + shipping)
    , order_items.price + order_items.freight_value as total_item_value
    -- Shipping cost as percentage of product price
    , order_items.freight_value / nullif(order_items.price, 0) as freight_pct_of_price
    
    -- Order Attributes
    , orders.customer_unique_id
    , orders.order_status
    , orders.is_delivered
    , orders.is_in_progress
    , orders.is_canceled
    , orders.order_purchase_timestamp_et
    , orders.order_delivered_customer_date_et
    , orders.is_delivered_on_time
    , orders.days_to_delivery
    , orders.delivery_speed_category
    , orders.customer_city
    , orders.customer_state
    , orders.review_score
    , orders.review_sentiment
    , orders.has_review
    , orders.total_payment_value
    , orders.total_payment_installments

    -- Product attributes
    , product.product_name_length
    , product.product_description_length
    , product.product_category_name
    , product.product_category_name_english
    , product.product_weight_g
    , product.product_length_cm
    , product.product_height_cm
    , product.product_width_cm
    
    -- Product volume in cubic centimeters (L × W × H)
    , product.product_length_cm * product.product_height_cm * product.product_width_cm as product_volume_cm3
    
    -- Volumetric weight (shipping industry standard: volume ÷ 6000)
    , (product.product_length_cm * product.product_height_cm * product.product_width_cm) / 6000.0 as volumetric_weight_kg
    
    -- Chargeable weight for shipping (higher of actual weight vs volumetric weight)
    , greatest(
        product.product_weight_g / 1000.0,
        (product.product_length_cm * product.product_height_cm * product.product_width_cm) / 6000.0
    ) as chargeable_weight_kg
    
    -- Freight cost per kg 
    , order_items.freight_value / nullif(
        greatest(
            product.product_weight_g / 1000.0,
            (product.product_length_cm * product.product_height_cm * product.product_width_cm) / 6000.0
        ), 0
    ) as freight_per_kg
    
    -- Size category based on volume 
    , case 
        when (product.product_length_cm * product.product_height_cm * product.product_width_cm) < 1000 then 'small'
        when (product.product_length_cm * product.product_height_cm * product.product_width_cm) < 10000 then 'medium'
        when (product.product_length_cm * product.product_height_cm * product.product_width_cm) < 100000 then 'large'
        else 'extra_large'
    end as product_size_category
    
    -- Heavy item flag (>5kg requires special handling)
    , product.product_weight_g > 5000 as is_heavy_item
    
    -- High-value item flag (>$100 may need insurance/tracking)
    , order_items.price > 100 as is_high_value_item
    
    -- Product has photos (impacts conversion)
    , product.product_photos_qty > 0 as has_photos
    
    -- Product has detailed description (>100 chars)
    , product.product_description_length > 100 as has_detailed_description
    
    -- Seller info
    , seller.seller_city
    , seller.seller_state
    , seller.seller_zip_code_prefix
    , seller.seller_geolocation_latitude
    , seller.seller_geolocation_longitude

from {{ ref('stg_order_items') }} order_items
left join {{ ref('int_order') }} orders on order_items.order_id = orders.order_id
left join {{ ref('int_products') }} product on order_items.product_id = product.product_id
left join {{ ref('int_sellers') }} seller on order_items.seller_id = seller.seller_id