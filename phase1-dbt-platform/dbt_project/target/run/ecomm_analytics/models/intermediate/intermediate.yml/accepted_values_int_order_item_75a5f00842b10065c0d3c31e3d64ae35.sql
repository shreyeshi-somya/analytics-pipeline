select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        product_size_category as value_field,
        count(*) as n_records

    from "analytics"."main_intermediate"."int_order_items"
    group by product_size_category

)

select *
from all_values
where value_field not in (
    'small','medium','large','extra_large'
)



      
    ) dbt_internal_test