-- Rows come from staging.tax_parcel_raw, which `gradlew ingestData` loads; see StagingTransformer.
-- Owner name, owner mailing address and the homestead exemption code are dropped upstream, in
-- prepareTaxParcels, so they never reach staging either.

create table gis.tax_parcel (
    id             bigint generated always as identity primary key,
    parcel_id      text not null unique,
    address        text not null,
    land_use_code  text not null,
    class_code     text not null,
    -- the assessor leaves both blank on a few hundred parcels rather than writing a zero
    acres          numeric(10, 4),
    living_units   integer,
    geom           geometry(MultiPolygon, 4326) not null
);
create index tax_parcel_geom_idx on gis.tax_parcel using gist (geom);
