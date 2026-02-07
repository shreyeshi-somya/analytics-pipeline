
    
    

with all_values as (

    select
        payment_type as value_field,
        count(*) as n_records

    from "analytics"."main_intermediate"."int_order_payments__by_type"
    group by payment_type

)

select *
from all_values
where value_field not in (
    'credit_card','debit_card','voucher','boleto'
)


