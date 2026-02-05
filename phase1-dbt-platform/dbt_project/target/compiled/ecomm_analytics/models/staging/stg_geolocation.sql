

select
    geolocation_zip_code_prefix
    , geolocation_lat -- latitude
    , geolocation_lng   -- longitude
    , geolocation_city
    , geolocation_state

from "analytics"."raw"."geolocation"