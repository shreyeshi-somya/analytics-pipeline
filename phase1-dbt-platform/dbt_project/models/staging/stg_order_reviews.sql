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
    , (review_comment_title is not null or review_comment_message is not null) as is_comment_present
    , review_creation_date
    , {{ convert_to_timezone('review_creation_date') }} as review_creation_date_et
    , review_answer_timestamp
    , {{ convert_to_timezone('review_answer_timestamp') }} as review_answer_timestamp_et

from {{ source('raw', 'order_reviews') }}