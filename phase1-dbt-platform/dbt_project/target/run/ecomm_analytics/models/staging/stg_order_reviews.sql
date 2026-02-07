
  
    
    

    create  table
      "analytics"."main_staging"."stg_order_reviews__dbt_tmp"
  
    as (
      

select
    review_id
    , order_id
    , review_score
    , review_comment_title
    , review_comment_message
    , (case when review_comment_title is not null and review_comment_message is not null then true else false end) as is_comment_present
    , review_creation_date
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (review_creation_date::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as review_creation_date_et
    , review_answer_timestamp
    , 
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    (review_answer_timestamp::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE 'America/New_York')
 as review_answer_timestamp_et

from "analytics"."raw"."order_reviews"
    );
  
  