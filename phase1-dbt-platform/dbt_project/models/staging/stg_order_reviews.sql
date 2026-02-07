{{
    config(
        materialized = 'table',
        schema = 'staging'
    )
}}

select
    review_id
    , order_id
    , review_score
    , review_comment_title
    , review_comment_message
    , (case when review_comment_title is not null and review_comment_message is not null then true else false end) as is_comment_present
    , review_creation_date
    , {{ convert_to_timezone('review_creation_date') }} as review_creation_date_et
    , review_answer_timestamp
    , {{ convert_to_timezone('review_answer_timestamp') }} as review_answer_timestamp_et

from {{ source('raw', 'order_reviews') }}