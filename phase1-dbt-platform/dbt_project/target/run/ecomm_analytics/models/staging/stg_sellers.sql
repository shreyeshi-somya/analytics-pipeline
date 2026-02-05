
  
    
    

    create  table
      "analytics"."main_staging"."stg_sellers__dbt_tmp"
  
    as (
      

select
    seller_id
    , seller_zip_code_prefix
    , seller_city
    , seller_state

from "analytics"."raw"."sellers"
    );
  
  