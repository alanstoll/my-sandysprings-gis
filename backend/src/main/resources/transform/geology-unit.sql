truncate gis.geology_unit;

-- Left joins: a unit either table does not know still belongs on the map, only unnamed. The source
-- unit is stored without its map's prefix (52|fg3 becomes fg3): the prefix is source_map again.
insert into gis.geology_unit (map_unit, name, age, geomaterial, description, identity_confidence,
                              source_map, source_unit, source_name, source_age, source_geomaterial,
                              source_description, geom)
select u.map_unit, d.name, d.age, d.geomaterial, d.description, u.identity_confidence,
       u.source_map, split_part(u.source_unit, '|', 2), s.name, s.age, s.geomaterial, s.description,
       u.geom
from staging.geology_unit_raw u
left join staging.geology_dmu_raw d on d.map_unit = u.map_unit
left join staging.geology_source_dmu_raw s on s.source_unit = u.source_unit;
