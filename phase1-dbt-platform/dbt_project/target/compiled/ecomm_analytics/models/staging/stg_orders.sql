

select
    order_id
    , customer_id
    , order_status
    , order_purchase_timestamp
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (order_purchase_timestamp::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as order_purchase_timestamp_et
    , order_approved_at
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (order_approved_at::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as order_approved_at_et
    , order_delivered_carrier_date
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (order_delivered_carrier_date::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as order_delivered_carrier_date_et
    , order_delivered_customer_date
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (order_delivered_customer_date::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as order_delivered_customer_date_et
    , order_estimated_delivery_date
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (order_estimated_delivery_date::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as order_estimated_delivery_date_et

from "analytics"."raw"."orders"