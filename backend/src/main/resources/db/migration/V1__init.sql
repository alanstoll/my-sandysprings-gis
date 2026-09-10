create extension if not exists postgis schema public;

grant usage on schema gis to geoserver;
alter default privileges in schema gis grant select on tables to geoserver;

create table gis.place (
    id   bigint generated always as identity primary key,
    name text not null,
    geom geometry(Point, 4326) not null
);
create index place_geom_idx on gis.place using gist (geom);

insert into gis.place (name, geom)
values ('Sandy Springs City Hall', ST_SetSRID(ST_MakePoint(-84.3776, 33.9290), 4326));
