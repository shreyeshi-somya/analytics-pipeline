{{
    config(
        materialized = 'table',
        schema = 'intermediate'
    )
}}

-- Deduplicate geolocation data by selecting most common lat/long for each zip code
-- (Raw data has multiple entries per zip due to varying precision)
with geo_counts as (
select
    geolocation_zip_code_prefix,
    geolocation_latitude,
    geolocation_longitude,
    geolocation_city,
    geolocation_state,
    count(*) as row_count

from {{ ref('stg_geolocation') }}
{{ dbt_utils.group_by(5) }}
)

select
    geolocation_zip_code_prefix,
    geolocation_latitude,
    geolocation_longitude,
    geolocation_city,
    geolocation_state

from geo_counts
qualify row_number() over (partition by geolocation_zip_code_prefix order by row_count desc) = 1