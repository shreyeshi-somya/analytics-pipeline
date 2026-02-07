
  
    
    

    create  table
      "analytics"."main_intermediate"."int_order__dbt_tmp"
  
    as (
      

select
    orders.order_id
    , orders.customer_id
    , orders.order_status
    , orders.order_purchase_timestamp_et
    , orders.order_payment_approved_at_et
    , orders.order_sent_to_carrier_date_et
    , orders.order_delivered_customer_date_et
    , orders.order_estimated_delivery_date_et
    
    -- Order Level Flags
    , (orders.order_status != 'canceled' and orders.order_delivered_customer_date_et is not null) as is_delivered
    , (orders.order_status = 'canceled') as is_canceled
    , (orders.order_delivered_customer_date_et <= orders.order_estimated_delivery_date_et) as is_delivered_on_time
    , order_status in ('approved', 'invoiced', 'processing', 'shipped') as is_in_progress
    
    -- Order Level Calculations
    , date_diff('day', orders.order_purchase_timestamp_et, orders.order_sent_to_carrier_date_et) as days_from_purchase_to_sent_to_carrier
    , date_diff('day', orders.order_sent_to_carrier_date_et, orders.order_delivered_customer_date_et) as days_in_transit
    , date_diff('day', orders.order_purchase_timestamp_et, orders.order_delivered_customer_date_et) as days_to_delivery
    , date_diff('day', orders.order_estimated_delivery_date_et, orders.order_delivered_customer_date_et) as days_late

    -- Delivery speed category
    , case 
        when days_to_delivery <= 3 then 'express'
        when days_to_delivery <= 7 then 'fast'
        when days_to_delivery <= 14 then 'standard'
        when days_to_delivery <= 30 then 'slow'
        else 'very_slow'
    end as delivery_speed_category

    -- Review Details
    , reviews.review_id
    , reviews.review_score
    , reviews.review_comment_title
	, reviews.review_comment_message
	, reviews.is_comment_present
	, reviews.review_creation_date_et 
	, reviews.review_answer_timestamp_et 

    -- Review sentiment (based on score)
    , case 
        when reviews.review_score >= 4 then 'positive'
        when reviews.review_score = 3 then 'neutral'
        when reviews.review_score <= 2 then 'negative'
        else null
    end as review_sentiment

    -- Customer left review flag
    , reviews.review_id is not null as has_review
    , date_diff('day', order_delivered_customer_date_et, reviews.review_creation_date_et) as days_to_review
    , date_diff('day', order_delivered_customer_date_et, reviews.review_creation_date_et) <= 3 as is_quick_review
    
    -- Payment Details
    , (orders.order_payment_approved_at is not null and payments.order_id is null) as is_payment_details_missing
    , payments.total_payment_value
    , payments.total_payment_installments
    , payments.avg_installment_value
    , payments.payment_type_count
    , payments.first_payment_type
    , payments.primary_payment_type
    , payments.voucher_payment_value
    , payments.debit_card_payment_value
    , payments.credit_card_payment_value
    , payments.boleto_payment_value
    , payments.voucher_payment_installments
    , payments.debit_card_payment_installments
    , payments.credit_card_payment_installments
    , payments.boleto_payment_installments
    , payments.avg_voucher_payment_installments
    , payments.avg_debit_card_payment_installments
    , payments.avg_credit_card_payment_installments
    , payments.avg_boleto_payment_installments
    , payments.used_multiple_payment_methods
    , payments.used_installments
    , payments.primary_payment_category
    , payments.is_high_installment_count

from "analytics"."main_staging"."stg_orders" orders   
left join "analytics"."main_intermediate"."int_order_reviews" reviews on orders.order_id = reviews.order_id
left join "analytics"."main_intermediate"."int_order_payments" payments on orders.order_id = payments.order_id
    );
  
  