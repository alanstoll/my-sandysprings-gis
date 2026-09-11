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

create table staging.acs_bg_geom_raw (
    id    integer primary key,
    geoid varchar,
    geom  geometry(MultiPolygon, 4326)
);

insert into staging.acs_bg_geom_raw
values (1, '130890000011', ST_Multi(ST_GeomFromText('POLYGON((-84.40 33.90,-84.39 33.90,-84.39 33.91,-84.40 33.91,-84.40 33.90))', 4326))),
       (2, '130890000012', ST_Multi(ST_GeomFromText('POLYGON((-84.39 33.90,-84.38 33.90,-84.38 33.91,-84.39 33.91,-84.39 33.90))', 4326))),
       (3, '130890000013', ST_Multi(ST_GeomFromText('POLYGON((-84.38 33.90,-84.37 33.90,-84.37 33.91,-84.38 33.91,-84.38 33.90))', 4326)));

-- ogr2ogr loads the csv without types, so these are varchar like the real staging table.
-- Columns run total, white, black, aian, asian, nhpi, other, two-or-more, hispanic, each estimate
-- followed by its margin. Row 1 has a clear winner, row 2's top two are inside their combined
-- margin, row 3 checks that a winner other than white survives the ranking.
create table staging.acs_bg_data_raw (
    id          integer primary key,
    geoid       varchar,
    b03002_001e varchar, b03002_001m varchar,
    b03002_003e varchar, b03002_003m varchar,
    b03002_004e varchar, b03002_004m varchar,
    b03002_005e varchar, b03002_005m varchar,
    b03002_006e varchar, b03002_006m varchar,
    b03002_007e varchar, b03002_007m varchar,
    b03002_008e varchar, b03002_008m varchar,
    b03002_009e varchar, b03002_009m varchar,
    b03002_012e varchar, b03002_012m varchar
);

insert into staging.acs_bg_data_raw
values (1, '130890000011', '1000', '80', '800', '50', '100', '30', '0', '10',
        '50', '20', '0', '10', '0', '10', '50', '20', '0', '10'),
       (2, '130890000012', '900', '150', '380', '110', '400', '120', '0', '10',
        '50', '20', '0', '10', '0', '10', '20', '15', '50', '25'),
       (3, '130890000013', '900', '70', '200', '30', '50', '20', '0', '10',
        '50', '20', '0', '10', '0', '10', '0', '10', '600', '40');
