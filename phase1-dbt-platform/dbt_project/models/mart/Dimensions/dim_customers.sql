{{
    config(
        materialized = 'table',
        schema = 'core'
    )
}}

select
    customer_unique_id

    -- Most recent address (from latest order)
    , max_by(customer_city, order_purchase_timestamp_et) as customer_city
    , max_by(customer_state, order_purchase_timestamp_et) as customer_state
    , max_by(customer_zip_code_prefix, order_purchase_timestamp_et) as customer_zip_code_prefix
    , max_by(customer_geolocation_latitude, order_purchase_timestamp_et) as customer_geolocation_latitude
    , max_by(customer_geolocation_longitude, order_purchase_timestamp_et) as customer_geolocation_longitude
    , max_by(customer_state_name, order_purchase_timestamp_et) as customer_state_name
    , max_by(customer_region, order_purchase_timestamp_et) as customer_region

    -- Aggregated metrics
    , count(order_id) as total_orders_all_statuses
    , count(case when is_delivered then order_id else null end) as total_delivered_orders
    , count(case when is_in_progress then order_id else null end) as in_progress_orders
    , count(case when is_canceled then order_id else null end) as canceled_orders
    , canceled_orders::float / nullif(total_orders_all_statuses,0) as cancellation_rate
    , count(case when is_delivered then order_id end) > 1 as has_repeat_orders
    
    , sum(case when is_delivered then total_payment_value else 0 end) as lifetime_value
    , max(case when is_delivered then order_purchase_timestamp_et end) as last_order_date
    , min(case when is_delivered then order_purchase_timestamp_et end) as first_order_date

    -- Days between Orders
    , datediff('day', first_order_date, last_order_date) as customer_lifetime_days
    , customer_lifetime_days::float / nullif(total_delivered_orders - 1, 0) as avg_days_between_orders
    
     -- Payment behavior
    , count(case when used_voucher then order_id end)::float / nullif(count(order_id), 0) as pct_orders_paid_with_voucher
    , count(case when used_credit_card then order_id end)::float / nullif(count(order_id), 0) as pct_orders_paid_with_credit_card
    , mode(primary_payment_type) as dominant_payment_type
    
    -- Review metrics
    , avg(case when has_review then review_score end) as avg_review_score
    , count(case when has_review then order_id end) as reviewed_orders
    , count(case when has_review then order_id end)::float / nullif(total_delivered_orders,0) as review_rate

from {{ ref('int_order') }}
{{ dbt_utils.group_by(1) }}