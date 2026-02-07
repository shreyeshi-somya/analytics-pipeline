
    
    

with all_values as (

    select
        delivery_speed_category as value_field,
        count(*) as n_records

    from "analytics"."main_intermediate"."int_order"
    group by delivery_speed_category

)

select *
from all_values
where value_field not in (
    'express','fast','standard','slow','very_slow'
)


