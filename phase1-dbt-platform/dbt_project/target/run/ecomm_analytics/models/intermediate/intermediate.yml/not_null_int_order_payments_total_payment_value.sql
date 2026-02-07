select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_payment_value
from "analytics"."main_intermediate"."int_order_payments"
where total_payment_value is null



      
    ) dbt_internal_test