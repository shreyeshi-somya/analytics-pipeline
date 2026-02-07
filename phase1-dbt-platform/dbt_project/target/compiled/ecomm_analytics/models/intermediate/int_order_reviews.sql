

with order_reviews AS (
select 
	order_id
	, review_id
	, review_score
	, listagg(review_comment_title, ', ') over (partition by order_id) as review_comment_title
	, listagg(review_comment_message, ', ') over (partition by order_id) as review_comment_message
    , (case 
        when listagg(review_comment_title, ', ') over (partition by order_id) is not null or
             listagg(review_comment_message, ', ') over (partition by order_id) is not null
        then true
        else false 
    end) as is_comment_present
	, review_creation_date_et 
	, review_answer_timestamp_et 
    -- Earliest review timestamp for the order
	, min(review_answer_timestamp_et) over (partition by order_id) as first_review_answer_timestamp_et 
    -- Calculate days between this review and the first review for this order
    , date_diff('day', first_review_answer_timestamp_et, review_answer_timestamp_et) as days_since_first_review
from "analytics"."main_staging"."stg_order_reviews"
)

select 
	order_id	
	, review_id
	, review_score
	, review_comment_title
	, review_comment_message
	, is_comment_present
	, review_creation_date_et 
	, review_answer_timestamp_et 
	
from order_reviews
-- Keep only reviews within 1 day of the first review (This filters out late reviews that might be data errors)
where (days_since_first_review is null or days_since_first_review <= 1)
-- Among the remaining reviews, take the most recent one
qualify row_number() over (partition by order_id order by review_answer_timestamp_et desc) = 1