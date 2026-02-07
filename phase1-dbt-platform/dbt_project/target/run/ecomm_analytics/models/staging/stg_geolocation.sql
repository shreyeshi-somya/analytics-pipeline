
  
    
    

    create  table
      "analytics"."main_staging"."stg_geolocation__dbt_tmp"
  
    as (
      

select
    geolocation_zip_code_prefix
    , geolocation_lat as geolocation_latitude 
    , geolocation_lng as geolocation_longitude
    , geolocation_city
    , geolocation_state

from "analytics"."raw"."geolocation"
    );
  
  