{{
    config(
        materialized = 'table',
        schema = 'staging'
    )
}}

select
    order_id
    , customer_id
    , order_status
    , order_purchase_timestamp
    , {{ convert_to_timezone('order_purchase_timestamp') }} as order_purchase_timestamp_et
    -- Add missing payment approval timestamps for orders that reached post-approval statuses
    -- If approved/invoiced/processed/shipped/delivered, order must have been approved - use purchase time as proxy
    , coalesce(order_approved_at,
        (case when order_status in ('approved', 'invoiced', 'processing', 'shipped', 'delivered')
              then order_purchase_timestamp
              else null 
        end)
    ) as order_payment_approved_at
    , {{ convert_to_timezone('order_payment_approved_at') }} as order_payment_approved_at_et
    , order_delivered_carrier_date as order_sent_to_carrier_date
    , {{ convert_to_timezone('order_delivered_carrier_date') }} as order_sent_to_carrier_date_et
    , order_delivered_customer_date
    , {{ convert_to_timezone('order_delivered_customer_date') }} as order_delivered_customer_date_et
    , order_estimated_delivery_date
    , {{ convert_to_timezone('order_estimated_delivery_date') }} as order_estimated_delivery_date_et

from {{ source('raw', 'orders') }}