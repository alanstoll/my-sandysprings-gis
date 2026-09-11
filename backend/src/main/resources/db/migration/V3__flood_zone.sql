-- Rows come from staging.flood_zone_raw, which `gradlew ingestData` loads; see StagingTransformer.

create table gis.flood_zone (
    id      bigint generated always as identity primary key,
    zone    text not null,
    subtype text,
    sfha    boolean not null,
    geom    geometry(MultiPolygon, 4326) not null
);
create index flood_zone_geom_idx on gis.flood_zone using gist (geom);
