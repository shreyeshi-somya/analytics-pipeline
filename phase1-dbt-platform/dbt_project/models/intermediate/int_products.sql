{{
    config(
        materialized = 'table',
        schema = 'intermediate'
    )
}}

select
    product.product_id
    , product.product_category_name
    , product.product_name_length
    , product.product_description_length
    , product.product_photos_qty 
    , product.product_weight_g 
    , product.product_length_cm
    , product.product_height_cm
    , product.product_width_cm
    , product_category_name.product_category_name_english
    , product_category_name.broad_category

from {{ ref('stg_products') }} product
left join {{ ref('stg_product_category_name') }} product_category_name on product.product_category_name = product_category_name.product_category_name