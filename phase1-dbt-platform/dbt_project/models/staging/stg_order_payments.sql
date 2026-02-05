{{
    config(
        materialized = 'table',
        schema = 'staging'
    )
}}

select
    order_id
    , payment_sequential
    , payment_type
    , payment_installments
    , payment_value

from {{ source('raw', 'order_payments') }}