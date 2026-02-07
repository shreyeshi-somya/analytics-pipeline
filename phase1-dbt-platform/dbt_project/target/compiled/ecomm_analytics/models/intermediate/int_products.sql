

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

from "analytics"."main_staging"."stg_products" product
left join "analytics"."main_staging"."stg_product_category_name" product_category_name on product.product_category_name = product_category_name.product_category_name