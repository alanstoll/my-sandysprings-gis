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

-- ogr2ogr loads the csv without types, so these are varchar like the real staging table. Row 1 has
-- a clear predominant category, row 2's top two sit inside their combined margin, row 3 checks that
-- a winner other than white survives the ranking. The age bands are flat so the derived shares are
-- easy to read: row 1 is 8 x 25 under 18 and 12 x 25 over 65 of 1000 people, so 20% and 30%.
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
    b03002_012e varchar, b03002_012m varchar,
    b01001_001e varchar, b01001_001m varchar,
    b01001_003e varchar, b01001_003m varchar,
    b01001_004e varchar, b01001_004m varchar,
    b01001_005e varchar, b01001_005m varchar,
    b01001_006e varchar, b01001_006m varchar,
    b01001_027e varchar, b01001_027m varchar,
    b01001_028e varchar, b01001_028m varchar,
    b01001_029e varchar, b01001_029m varchar,
    b01001_030e varchar, b01001_030m varchar,
    b01001_020e varchar, b01001_020m varchar,
    b01001_021e varchar, b01001_021m varchar,
    b01001_022e varchar, b01001_022m varchar,
    b01001_023e varchar, b01001_023m varchar,
    b01001_024e varchar, b01001_024m varchar,
    b01001_025e varchar, b01001_025m varchar,
    b01001_044e varchar, b01001_044m varchar,
    b01001_045e varchar, b01001_045m varchar,
    b01001_046e varchar, b01001_046m varchar,
    b01001_047e varchar, b01001_047m varchar,
    b01001_048e varchar, b01001_048m varchar,
    b01001_049e varchar, b01001_049m varchar,
    b25044_001e varchar, b25044_001m varchar,
    b25044_003e varchar, b25044_003m varchar,
    b25044_010e varchar, b25044_010m varchar
);

insert into staging.acs_bg_data_raw
values
       (1, '130890000011', '1000', '80', '800', '50', '100', '30', '0', '10', '50', '20', '0', '10', '0', '10', '50', '20', '0', '10', '1000', '20', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '25', '5', '400', '10', '40', '4', '0', '4'),
       (2, '130890000012', '900', '150', '380', '110', '400', '120', '0', '10', '50', '20', '0', '10', '0', '10', '20', '15', '50', '25', '900', '20', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '5', '300', '10', '0', '4', '30', '4'),
       (3, '130890000013', '900', '70', '200', '30', '50', '20', '0', '10', '50', '20', '0', '10', '0', '10', '0', '10', '600', '40', '900', '20', '20', '5', '20', '5', '20', '5', '20', '5', '20', '5', '20', '5', '20', '5', '20', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '10', '5', '350', '10', '0', '4', '0', '4');

create table staging.acs_tract_geom_raw (
    id    integer primary key,
    geoid varchar,
    geom  geometry(MultiPolygon, 4326)
);

insert into staging.acs_tract_geom_raw
values (1, '13089000001', ST_Multi(ST_GeomFromText('POLYGON((-84.40 33.92,-84.38 33.92,-84.38 33.94,-84.40 33.94,-84.40 33.92))', 4326))),
       (2, '13089000002', ST_Multi(ST_GeomFromText('POLYGON((-84.38 33.92,-84.36 33.92,-84.36 33.94,-84.38 33.94,-84.38 33.92))', 4326)));

-- Tract 2 carries the ACS's "not available" sentinel in every median, which is the case the
-- transform has to turn into null rather than a very negative dollar amount.
create table staging.acs_tract_data_raw (
    id          integer primary key,
    geoid       varchar,
    b19013_001e varchar, b19013_001m varchar,
    b25077_001e varchar, b25077_001m varchar,
    b25064_001e varchar, b25064_001m varchar,
    b25003_001e varchar, b25003_001m varchar,
    b25003_003e varchar, b25003_003m varchar,
    b08301_001e varchar, b08301_001m varchar,
    b08301_003e varchar, b08301_003m varchar,
    b08301_004e varchar, b08301_004m varchar,
    b08301_010e varchar, b08301_010m varchar,
    b08301_016e varchar, b08301_016m varchar,
    b08301_017e varchar, b08301_017m varchar,
    b08301_018e varchar, b08301_018m varchar,
    b08301_019e varchar, b08301_019m varchar,
    b08301_020e varchar, b08301_020m varchar,
    b08301_021e varchar, b08301_021m varchar
);

insert into staging.acs_tract_data_raw
values
       (1, '13089000001', '120000', '9000', '550000', '30000', '1800', '150', '800', '25', '200', '20', '1000', '15', '600', '15', '100', '15', '50', '15', '10', '15', '10', '15', '20', '15', '60', '15', '50', '15', '100', '15'),
       (2, '13089000002', '-666666666', '9000', '-666666666', '30000', '-666666666', '150', '400', '25', '300', '20', '500', '15', '250', '15', '50', '15', '25', '15', '5', '15', '5', '15', '10', '15', '30', '15', '25', '15', '100', '15');

create table staging.tax_parcel_raw (
    id        integer primary key,
    parcelid  varchar,
    address   varchar,
    lucode    varchar,
    classcode varchar,
    landacres double precision,
    livunits  integer,
    geom      geometry(MultiPolygon, 4326)
);

-- one row per category the style draws, plus the unaddressed vacant lot the county writes as
-- "0 <street>" with neither an acreage nor a unit count
insert into staging.tax_parcel_raw
values (1, '17 011900050296', '44 BARBARA LN NW', '101', 'R3', 0.4687, 1, ST_Multi(ST_GeomFromText(
           'POLYGON((-84.40 33.92,-84.399 33.92,-84.399 33.921,-84.40 33.921,-84.40 33.92))', 4326))),
       (2, '17 010000010001', '100 PERIMETER CENTER PL', '107', 'R3', 0.05, 1, ST_Multi(ST_GeomFromText(
           'POLYGON((-84.35 33.93,-84.348 33.93,-84.348 33.932,-84.35 33.932,-84.35 33.93))', 4326))),
       (3, '17 010000010002', '0 GLENLAKE PKWY', '100', 'C3', null, null, ST_Multi(ST_GeomFromText(
           'POLYGON((-84.36 33.935,-84.359 33.935,-84.359 33.936,-84.36 33.936,-84.36 33.935))', 4326))),
       (4, '17 010000010003', '20 PERIMETER PARK', '2A1', 'C5', 20.09, 250, ST_Multi(ST_GeomFromText(
           'POLYGON((-84.34 33.94,-84.338 33.94,-84.338 33.942,-84.34 33.942,-84.34 33.94))', 4326))),
       (5, '17 010000010004', '100 MOUNT VERNON HWY', '612', 'E1', 11.45, 0, ST_Multi(ST_GeomFromText(
           'POLYGON((-84.37 33.92,-84.368 33.92,-84.368 33.922,-84.37 33.922,-84.37 33.92))', 4326))),
       (6, '17 010000010005', '500 HAMMOND DR', '355', 'C3', 0.09, 0, ST_Multi(ST_GeomFromText(
           'POLYGON((-84.36 33.93,-84.359 33.93,-84.359 33.931,-84.36 33.931,-84.36 33.93))', 4326)));
