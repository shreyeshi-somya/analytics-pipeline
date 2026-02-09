{{
    config(
        materialized = 'table',
        schema = 'staging'
    )
}}

select
    geo.geolocation_zip_code_prefix
    , geo.geolocation_lat as geolocation_latitude
    , geo.geolocation_lng as geolocation_longitude
    , geo.geolocation_city
    , geo.geolocation_state
    , states.state_name as geolocation_state_name
    , states.region as geolocation_region

from {{ source('raw', 'geolocation') }} geo
left join {{ ref('brazil_states_with_regions') }} states on geo.geolocation_state = states.state_abbreviation