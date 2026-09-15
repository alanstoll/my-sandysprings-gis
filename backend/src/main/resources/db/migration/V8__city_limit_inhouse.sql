-- Our own city limit, as against the City's published one in gis.city_limit. Same outline, moved
-- onto the parcel fabric it is measured against; see transform/city-limit-inhouse.sql. Rows come
-- from gis.city_limit rather than from staging.

create table gis.city_limit_inhouse (
    id    bigint generated always as identity primary key,
    name  text not null,
    -- the correction this layer exists to apply, recorded next to the geometry it produced
    dx_ft numeric(8, 2) not null,
    dy_ft numeric(8, 2) not null,
    geom  geometry(MultiPolygon, 4326) not null
);
create index city_limit_inhouse_geom_idx on gis.city_limit_inhouse using gist (geom);
