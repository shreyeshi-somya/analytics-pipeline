{{
    config(
        materialized = 'table',
        schema = 'intermediate'
    )
}}

select
    customers.customer_id
    , customers.customer_unique_id
    , customers.customer_zip_code_prefix
    , customers.customer_city
    , customers.customer_state
    , geolocation.geolocation_latitude as customer_geolocation_latitude
    , geolocation.geolocation_longitude as customer_geolocation_longitude
    -- TODO: check if these match to the values from customer table
    , geolocation.geolocation_city as customer_geolocation_city
    , geolocation.geolocation_state as customer_geolocation_state

from {{ ref('stg_customers') }} customers
left join {{ ref('stg_geolocation') }} geolocation on customers.customer_zip_code_prefix = geolocation.geolocation_zip_code_prefix