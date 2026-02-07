select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

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



      
    ) dbt_internal_test