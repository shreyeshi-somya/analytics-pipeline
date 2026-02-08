{{
    config(
        materialized = 'table',
        schema = 'intermediate'
    )
}}


select 
	order_id
	, payment_type
	, sum(payment_value) as payment_value
	, sum(payment_installments) as payment_installments
	, sum(payment_value)/nullif(sum(payment_installments),0) as avg_installment_value
    , count(*) as transaction_count
    -- First Payment Type
    , (case when min(payment_sequential) = 1 then true else false end) as is_first_payment_type

from {{ ref('stg_order_payments') }}
group by 1 ,2 