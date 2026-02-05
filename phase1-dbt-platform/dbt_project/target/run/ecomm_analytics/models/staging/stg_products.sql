
  
    
    

    create  table
      "analytics"."main_staging"."stg_products__dbt_tmp"
  
    as (
      

select 
    product_id
    , product_category_name
    , product_name_lenght as product_name_length
    , product_description_lenght as product_description_length
    , product_photos_qty -- number of product published photos
    , product_weight_g 
    , product_length_cm
    , product_height_cm
    , product_width_cm

from "analytics"."raw"."products"
    );
  
  