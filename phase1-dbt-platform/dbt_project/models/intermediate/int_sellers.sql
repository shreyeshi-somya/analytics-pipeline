{{
    config(
        materialized = 'table',
        schema = 'intermediate'
    )
}}


select
    sellers.seller_id
    , sellers.seller_zip_code_prefix
    , sellers.seller_city
    , sellers.seller_state
    , geolocation.geolocation_latitude as seller_geolocation_latitude
    , geolocation.geolocation_longitude as seller_geolocation_longitude
    , geolocation.geolocation_city as seller_geolocation_city
    , geolocation.geolocation_state as seller_geolocation_state

from {{ ref('stg_sellers') }} sellers
left join {{ ref('stg_geolocation') }} geolocation on sellers.seller_zip_code_prefix = geolocation.geolocation_zip_code_prefix