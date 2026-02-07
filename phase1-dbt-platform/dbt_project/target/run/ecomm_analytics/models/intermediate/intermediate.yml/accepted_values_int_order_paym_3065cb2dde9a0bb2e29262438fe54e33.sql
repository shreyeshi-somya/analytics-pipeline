select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        primary_payment_category as value_field,
        count(*) as n_records

    from "analytics"."main_intermediate"."int_order_payments"
    group by primary_payment_category

)

select *
from all_values
where value_field not in (
    'card','boleto','voucher','other'
)



      
    ) dbt_internal_test