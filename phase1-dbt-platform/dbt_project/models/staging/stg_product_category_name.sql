{{
    config(
        materialized = 'table',
        schema = 'staging'
    )
}}

select
    category.product_category_name
    , category.product_category_name_english
    , rollup.broad_category

from {{ source('raw', 'product_category_name') }} category
left join {{ ref('product_category_rollup') }} rollup on category.product_category_name_english = rollup.product_category_name