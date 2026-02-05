
  
    
    

    create  table
      "analytics"."main_staging"."stg_product_category_name__dbt_tmp"
  
    as (
      

select 
    product_category_name
    , product_category_name_english

from "analytics"."raw"."product_category_name"
    );
  
  