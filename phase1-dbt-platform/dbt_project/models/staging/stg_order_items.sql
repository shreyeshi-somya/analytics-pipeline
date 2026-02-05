{{
    config(
        materialized = 'table',
        schema = 'staging'
    )
}}

select
    order_id
    , order_item_id
    , product_id
    , seller_id
    , shipping_limit_date
    , {{ convert_to_timezone('shipping_limit_date') }} as shipping_limit_date_et
    , price
    , freight_value
    
from {{ source('raw', 'order_items') }}