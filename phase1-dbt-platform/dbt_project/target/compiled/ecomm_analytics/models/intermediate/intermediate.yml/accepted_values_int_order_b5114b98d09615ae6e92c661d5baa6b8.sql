
    
    

with all_values as (

    select
        review_sentiment as value_field,
        count(*) as n_records

    from "analytics"."main_intermediate"."int_order"
    group by review_sentiment

)

select *
from all_values
where value_field not in (
    'positive','neutral','negative'
)


