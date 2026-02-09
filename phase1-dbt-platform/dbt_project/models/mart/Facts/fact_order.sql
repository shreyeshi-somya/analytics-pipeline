{{
    config(
        materialized = 'table',
        schema = 'core'
    )
}}

select
    -- Order Details
    orders.order_id
    , orders.customer_id
    , orders.order_status
    , orders.order_purchase_timestamp_et
    , orders.order_payment_approved_at_et
    , orders.order_sent_to_carrier_date_et
    , orders.order_delivered_customer_date_et
    , orders.order_estimated_delivery_date_et

    -- Order Flags
    , orders.is_delivered
    , orders.is_canceled
    , orders.is_delivered_on_time
    , orders.is_in_progress

    -- Delivery Metrics
    , orders.days_from_purchase_to_sent_to_carrier
    , orders.days_in_transit
    , orders.days_to_delivery
    , orders.days_late
    , orders.delivery_speed_category

    -- Customer Details
    , orders.customer_unique_id
    , orders.customer_zip_code_prefix
    , orders.customer_city
    , orders.customer_state
    , orders.customer_geolocation_latitude
    , orders.customer_geolocation_longitude
    , orders.customer_state_name
    , orders.customer_region

    -- Review Details
    , orders.review_id
    , orders.review_score
    , orders.review_comment_title
    , orders.review_comment_message
    , orders.is_comment_present
    , orders.review_creation_date_et
    , orders.review_answer_timestamp_et
    , orders.review_sentiment
    , orders.has_review
    , orders.days_to_review
    , orders.is_quick_review

    -- Payment Details
    , orders.is_payment_details_missing
    , orders.total_payment_value
    , orders.total_payment_installments
    , orders.avg_installment_value

    , orders.used_installments
    , orders.is_high_installment_count

    , orders.payment_type_count
    , orders.used_multiple_payment_methods
    , orders.first_payment_type
    , orders.primary_payment_type
    , orders.primary_payment_category

    , orders.used_voucher
    , orders.voucher_payment_value
    , orders.voucher_payment_installments
    , orders.avg_voucher_payment_installments

    , orders.used_debit_card
    , orders.debit_card_payment_value
    , orders.debit_card_payment_installments
    , orders.avg_debit_card_payment_installments

    , orders.used_credit_card
    , orders.credit_card_payment_value
    , orders.credit_card_payment_installments
    , orders.avg_credit_card_payment_installments

    , orders.used_boleto
    , orders.boleto_payment_value
    , orders.boleto_payment_installments
    , orders.avg_boleto_payment_installments

    -- Holiday Details
    , holidays.holiday_name
    , holidays.is_national as is_national_holiday
    , holidays.holiday_type
    , holidays.holiday_date is not null as is_holiday_order

from {{ ref('int_order') }} orders
left join {{ ref('brazilian_holidays') }} holidays on (orders.order_purchase_timestamp_et)::date = (holidays.holiday_date)::date