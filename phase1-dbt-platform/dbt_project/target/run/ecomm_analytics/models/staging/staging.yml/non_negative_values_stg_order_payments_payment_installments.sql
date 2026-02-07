select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

select *
from "analytics"."main_staging"."stg_order_payments"
where payment_installments < 0


      
    ) dbt_internal_test