-- Rows come from staging.city_limit_raw, which `gradlew ingestData` loads; see StagingTransformer.

create table gis.city_limit (
    id             bigint generated always as identity primary key,
    name           text not null,
    effective_date date not null,
    geom           geometry(MultiPolygon, 4326) not null
);
create index city_limit_geom_idx on gis.city_limit using gist (geom);
