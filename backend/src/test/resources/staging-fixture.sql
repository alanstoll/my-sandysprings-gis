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

create table staging.flood_zone_raw (
    id         integer primary key,
    fld_zone   varchar,
    zone_subty varchar,
    sfha_tf    varchar,
    geom       geometry(MultiPolygon, 4326)
);

-- one row per class the style draws, plus the minimal-hazard class it deliberately does not
insert into staging.flood_zone_raw
values (1, 'AE', null, 'T', ST_Multi(ST_GeomFromText('POLYGON((-84.40 33.92,-84.39 33.92,-84.39 33.93,-84.40 33.93,-84.40 33.92))', 4326))),
       (2, 'AE', 'FLOODWAY', 'T', ST_Multi(ST_GeomFromText('POLYGON((-84.395 33.922,-84.392 33.922,-84.392 33.928,-84.395 33.928,-84.395 33.922))', 4326))),
       (3, 'A', '', 'T', ST_Multi(ST_GeomFromText('POLYGON((-84.38 33.92,-84.37 33.92,-84.37 33.93,-84.38 33.93,-84.38 33.92))', 4326))),
       (4, 'X', '0.2 PCT ANNUAL CHANCE FLOOD HAZARD', 'F', ST_Multi(ST_GeomFromText('POLYGON((-84.41 33.91,-84.36 33.91,-84.36 33.94,-84.41 33.94,-84.41 33.91))', 4326))),
       (5, 'X', 'AREA OF MINIMAL FLOOD HAZARD', 'F', ST_Multi(ST_GeomFromText('POLYGON((-84.45 33.88,-84.26 33.88,-84.26 34.01,-84.45 34.01,-84.45 33.88))', 4326)));
