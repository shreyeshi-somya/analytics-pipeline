



select
    1
from "analytics"."main_staging"."stg_orders"

where not(not (order_status = 'canceled' and order_delivered_customer_date is not null))

