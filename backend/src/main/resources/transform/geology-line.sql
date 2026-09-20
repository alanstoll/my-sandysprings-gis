truncate gis.geology_line;

insert into gis.geology_line (type, concealed, geom)
select type, concealed = 'y', geom
from staging.geology_line_raw;
