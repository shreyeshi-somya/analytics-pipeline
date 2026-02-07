select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      



select
    1
from "analytics"."main_staging"."stg_orders"

where not(not (order_status = 'canceled' and order_delivered_customer_date is not null))


      
    ) dbt_internal_test