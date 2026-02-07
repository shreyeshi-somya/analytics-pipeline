select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      -- WARN: Canceled orders with delivery dates
-- This documents known edge cases (e.g., orders delivered then refunded/returned)
-- Acceptable at low volumes

select 
    order_id,
    order_status,
    order_purchase_timestamp_et,
    order_sent_to_carrier_date,
    order_delivered_customer_date
from "analytics"."main_staging"."stg_orders"
where order_status = 'canceled'
  and order_delivered_customer_date is not null
      
    ) dbt_internal_test