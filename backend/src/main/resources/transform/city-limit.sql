truncate gis.city_limit;

insert into gis.city_limit (name, effective_date, geom)
select cityname, to_date(effective_date, 'MM/DD/YY, HH12:MI AM'), geom
from staging.city_limit_raw;
