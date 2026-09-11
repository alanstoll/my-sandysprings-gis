-- Rows come from staging.acs_bg_geom_raw and staging.acs_bg_data_raw, which `gradlew ingestData`
-- loads; see StagingTransformer. One row per block group, one column per B03002 category, because
-- GeoServer renders one feature per polygon.

create table gis.acs_bg (
    id          bigint generated always as identity primary key,
    geoid       text not null unique,
    population  integer not null,
    white       integer not null,
    black       integer not null,
    aian        integer not null,
    asian       integer not null,
    nhpi        integer not null,
    other       integer not null,
    multiracial integer not null,
    hispanic    integer not null,
    -- The largest category and the runner-up, and whether the gap between them is inside their
    -- combined margin of error. At block group scale it often is, so the style draws the two
    -- together rather than claiming a winner the survey cannot support.
    predominant text not null,
    runner_up   text not null,
    ambiguous   boolean not null,
    geom        geometry(MultiPolygon, 4326) not null
);
create index acs_bg_geom_idx on gis.acs_bg using gist (geom);
