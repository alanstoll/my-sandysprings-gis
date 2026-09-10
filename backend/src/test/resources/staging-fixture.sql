-- Stands in for the ogr2ogr output that `gradlew ingestData` produces in development.

create schema staging;

create table staging.city_limit_raw (
    id             integer primary key,
    objectid       varchar,
    cityname       varchar,
    effective_date varchar,
    acres          varchar,
    geom           geometry(MultiPolygon, 4326)
);

insert into staging.city_limit_raw
values (1, '7', 'Sandy Springs', '11/30/05, 2:00 PM', '24,833.09', ST_Multi(ST_GeomFromText(
    'POLYGON((-84.45 33.88,-84.26 33.88,-84.26 34.01,-84.45 34.01,-84.45 33.88))', 4326)));
