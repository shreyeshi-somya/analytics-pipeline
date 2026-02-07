
  
    
    

    create  table
      "analytics"."main_staging"."stg_orders__dbt_tmp"
  
    as (
      

select
    order_id
    , customer_id
    , order_status
    , order_purchase_timestamp
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (order_purchase_timestamp::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as order_purchase_timestamp_et
    -- Add missing payment approval timestamps for orders that reached post-approval statuses
    -- If approved/invoiced/processed/shipped/delivered, order must have been approved - use purchase time as proxy
    , coalesce(order_approved_at,
        (case when order_status in ('approved', 'invoiced', 'processing', 'shipped', 'delivered')
              then order_purchase_timestamp
              else null 
        end)
    ) as order_payment_approved_at
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (order_payment_approved_at::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as order_payment_approved_at_et
    , order_delivered_carrier_date as order_sent_to_carrier_date
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (order_delivered_carrier_date::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as order_sent_to_carrier_date_et
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
    );
  
  