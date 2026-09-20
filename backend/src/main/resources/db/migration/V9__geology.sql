-- Rows come from staging.geology_unit_raw, geology_line_raw, geology_dmu_raw and
-- geology_source_dmu_raw, which `gradlew ingestData` loads; see StagingTransformer.

create table gis.geology_unit (
    id                  bigint generated always as identity primary key,
    -- the synthesis unit and its row in the national description table, absent where it has none
    map_unit            text not null,
    name                text,
    age                 text,
    geomaterial         text,
    description         text,
    identity_confidence text,
    -- the map the synthesis took this polygon from, what that map called it, and that map's own
    -- description of it: the detail the synthesis flattened
    source_map          text,
    source_unit         text,
    source_name         text,
    source_age          text,
    source_geomaterial  text,
    source_description  text,
    geom                geometry(MultiPolygon, 4326) not null
);
create index geology_unit_geom_idx on gis.geology_unit using gist (geom);

create table gis.geology_line (
    id        bigint generated always as identity primary key,
    type      text not null,
    concealed boolean not null,
    geom      geometry(MultiLineString, 4326) not null
);
create index geology_line_geom_idx on gis.geology_line using gist (geom);
