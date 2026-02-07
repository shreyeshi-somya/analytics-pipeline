-- ERROR: Too many canceled orders have delivery dates (> 5%)
-- This indicates a systemic data quality issue requiring investigation


select 
    count(distinct case when order_status = 'canceled' then order_id else null end) as total_canceled
    , count(distinct case when order_status = 'canceled' and order_delivered_customer_date is not null then order_id else null end) as count_with_delivery
    , round((count_with_delivery::float / total_canceled * 100), 2) as issue_rate_pct
    , 5.0 as threshold_pct
    , 'Issue rate exceeds acceptable threshold' as message
from {{ ref('stg_orders') }}
having (count_with_delivery::float / total_canceled) > 0.01