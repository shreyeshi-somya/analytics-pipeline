{{
    config(
        materialized = 'table',
        schema = 'staging'
    )
}}

select
    geolocation_zip_code_prefix
    , geolocation_lat as geolocation_latitude 
    , geolocation_lng as geolocation_longitude
    , geolocation_city
    , geolocation_state

from {{ source('raw', 'geolocation') }}