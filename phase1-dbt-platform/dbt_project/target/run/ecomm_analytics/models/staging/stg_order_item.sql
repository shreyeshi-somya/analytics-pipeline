
  
    
    

    create  table
      "analytics"."main_staging"."stg_order_item__dbt_tmp"
  
    as (
      

select
    order_id
    , order_item_id
    , product_id
    , seller_id
    , shipping_limit_date
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (shipping_limit_date::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as shipping_limit_date_et
    , price
    , freight_value
    
from "analytics"."raw"."order_items"
    );
  
  