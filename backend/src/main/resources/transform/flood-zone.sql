truncate gis.flood_zone;

insert into gis.flood_zone (zone, subtype, sfha, geom)
select fld_zone, nullif(zone_subty, ''), sfha_tf = 'T', geom
from staging.flood_zone_raw;
