-- The themes beyond race, split across two geographies. A theme is stored as its value plus the
-- margin of error on that value, not as a value plus a "reliable" flag: the margin is what the
-- survey actually published, and leaving the threshold to the style keeps the judgement of what is
-- too uncertain to draw with the cartography rather than baked in here, where changing it would
-- mean re-running the transform.
--
-- Shares are stored as percentages already divided out. The numerators are several columns wide in
-- the ACS and of no interest on their own, and a style cannot divide.

alter table gis.acs_bg
    add column age_65_plus      numeric(5, 2),
    add column age_65_plus_moe  numeric(5, 2),
    add column age_under_18     numeric(5, 2),
    add column age_under_18_moe numeric(5, 2),
    add column no_vehicle       numeric(5, 2),
    add column no_vehicle_moe   numeric(5, 2);

create table gis.acs_tract (
    id                bigint generated always as identity primary key,
    geoid             text not null unique,
    households        integer not null,
    workers           integer not null,
    income            integer,
    income_moe        integer,
    home_value        integer,
    home_value_moe    integer,
    gross_rent        integer,
    gross_rent_moe    integer,
    renter            numeric(5, 2),
    renter_moe        numeric(5, 2),
    -- B08301's nine exclusive leaves, folded into the six modes worth naming. Stored in full even
    -- though no style draws the split directly: predominant mode is "drove alone" in 150 of the 156
    -- tracts here, so the map shows shares instead, and the split answers a click.
    drove_alone       numeric(5, 2),
    carpooled         numeric(5, 2),
    transit           numeric(5, 2),
    walked            numeric(5, 2),
    bicycle           numeric(5, 2),
    -- taxi, motorcycle and the ACS's own "other means", kept together and kept apart from bicycle
    -- so the seven shares still sum to the whole
    other_mode        numeric(5, 2),
    worked_at_home    numeric(5, 2),
    worked_at_home_moe numeric(5, 2),
    -- everything except driving alone, the usual way of measuring this
    not_drove_alone     numeric(5, 2),
    not_drove_alone_moe numeric(5, 2),
    geom              geometry(MultiPolygon, 4326) not null
);
create index acs_tract_geom_idx on gis.acs_tract using gist (geom);

-- The ACS handbook's margin of error for a derived proportion, used by the transforms. It lives
-- next to the tables it serves because Flyway owns this schema and not staging; the geoserver role
-- only reads, so it never calls this.
--
-- The subtraction under the root is what makes it a proportion rather than a ratio: the numerator
-- is part of the denominator, so the two errors are correlated and partly cancel. The handbook
-- falls back to the ratio form when that would take the root of a negative number.
create function gis.share_moe(numerator numeric, numerator_moe numeric,
                              denominator numeric, denominator_moe numeric) returns numeric
    language sql immutable as $$
    select case
        when denominator is null or denominator = 0 then null
        when numerator_moe ^ 2 - (numerator / denominator) ^ 2 * denominator_moe ^ 2 >= 0
            then sqrt(numerator_moe ^ 2 - (numerator / denominator) ^ 2 * denominator_moe ^ 2)
                 / denominator * 100
        else sqrt(numerator_moe ^ 2 + (numerator / denominator) ^ 2 * denominator_moe ^ 2)
             / denominator * 100
    end
$$;
