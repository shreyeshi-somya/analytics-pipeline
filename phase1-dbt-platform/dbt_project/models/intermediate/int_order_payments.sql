{{
    config(
        materialized = 'table',
        schema = 'intermediate'
    )
}}



with order_payments_by_type as
(
    select 
        order_id
        , payment_type
        , payment_value
        , payment_installments
        , transaction_count
        , is_first_payment_type
        , row_number() over (partition by order_id order by payment_value desc) as payment_type_ranked_by_value
        , (case when payment_type = 'voucher' then true else false end) as used_voucher
        , (case when payment_type = 'debit_card' then true else false end) as used_debit_card
        , (case when payment_type = 'credit_card' then true else false end) as used_credit_card
        , (case when payment_type = 'boleto' then true else false end) as used_boleto

from {{ ref('int_order_payments__by_type') }}
)

select 
	order_id
    , sum(payment_value) as total_payment_value
	, sum(payment_installments) as total_payment_installments
	, sum(payment_value)/sum(payment_installments) as avg_installment_value
    , count(distinct payment_type) as payment_type_count
    , max(case when is_first_payment_type = true then payment_type else null end) as first_payment_type
    , max(case when payment_type_ranked_by_value = 1 then payment_type else null end) as primary_payment_type
	
	, sum(case when payment_type = 'voucher' then payment_value else 0 end) as voucher_payment_value
	, sum(case when payment_type = 'debit_card' then payment_value else 0 end) as debit_card_payment_value
	, sum(case when payment_type = 'credit_card' then payment_value else 0 end) as credit_card_payment_value
	, sum(case when payment_type = 'boleto' then payment_value else 0 end) as boleto_payment_value
	
	, sum(case when payment_type = 'voucher' then payment_installments else 0 end) as voucher_payment_installments
	, sum(case when payment_type = 'debit_card' then payment_installments else 0 end) as debit_card_payment_installments
	, sum(case when payment_type = 'credit_card' then payment_installments else 0 end) as credit_card_payment_installments
	, sum(case when payment_type = 'boleto' then payment_installments else 0 end) as boleto_payment_installments
	
	, coalesce(voucher_payment_value/voucher_payment_installments,0) as avg_voucher_payment_installments
	, coalesce(debit_card_payment_value/debit_card_payment_installments,0) as avg_debit_card_payment_installments
	, coalesce(credit_card_payment_value/credit_card_payment_installments,0) as avg_credit_card_payment_installments
	, coalesce(boleto_payment_value/boleto_payment_installments,0) as avg_boleto_payment_installments

	, bool_or(used_voucher) as used_voucher
	, bool_or(used_debit_card) as used_debit_card
	, bool_or(used_credit_card) as used_credit_card
	, bool_or(used_boleto) as used_boleto

    -- Used multiple payment methods (split payment)
    , payment_type_count > 1 as used_multiple_payment_methods

    -- Used installments flag
    , total_payment_installments > 1 as used_installments

    -- Primary payment method category
    , case 
        when primary_payment_type in ('credit_card', 'debit_card') then 'card'
        when primary_payment_type = 'boleto' then 'boleto'
        when primary_payment_type = 'voucher' then 'voucher'
        else 'other'
    end as primary_payment_category

    -- High installment count flag (>6 installments)
    , total_payment_installments > 6 as is_high_installment_count
    
from order_payments_by_type
group by 1 