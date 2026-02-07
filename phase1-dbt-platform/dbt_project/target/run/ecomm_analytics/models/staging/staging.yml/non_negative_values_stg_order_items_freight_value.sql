select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

select *
from "analytics"."main_staging"."stg_order_items"
where freight_value < 0


      
    ) dbt_internal_test