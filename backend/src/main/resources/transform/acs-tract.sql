truncate gis.acs_tract;

-- A median is published as one number, so it needs no arithmetic here, only the sentinel rule: the
-- ACS writes an unavailable value as a large negative number, and no income, value or rent is ever
-- legitimately negative, so one rule covers the whole family. Unlike the block group race counts
-- these really are suppressed, in 6% to 40% of tracts depending on the table.
with commute as (
    select d.geoid,
           d.b08301_001e::numeric as workers,
           d.b08301_001m::numeric as workers_moe,
           d.b08301_003e::numeric as drove_alone,
           d.b08301_021e::numeric as at_home,
           d.b08301_021m::numeric as at_home_moe,
           d.b08301_004e::numeric as carpooled,
           d.b08301_010e::numeric as transit,
           d.b08301_019e::numeric as walked,
           d.b08301_018e::numeric as bicycle,
           -- taxi, motorcycle and the ACS's own "other means"
           d.b08301_016e::numeric + d.b08301_017e::numeric + d.b08301_020e::numeric as other_mode,
           d.b08301_001e::numeric - d.b08301_003e::numeric as not_alone,
           sqrt(power(d.b08301_001m::numeric, 2) + power(d.b08301_003m::numeric, 2)) as not_alone_moe
    from staging.acs_tract_data_raw d
)
insert into gis.acs_tract (geoid, households, workers, income, income_moe, home_value,
                           home_value_moe, gross_rent, gross_rent_moe, renter, renter_moe,
                           drove_alone, carpooled, transit, walked, bicycle, other_mode,
                           worked_at_home, worked_at_home_moe,
                           not_drove_alone, not_drove_alone_moe, geom)
select d.geoid,
       d.b25003_001e::integer,
       c.workers::integer,
       nullif(greatest(d.b19013_001e::integer, -1), -1),
       nullif(greatest(d.b19013_001m::integer, -1), -1),
       nullif(greatest(d.b25077_001e::integer, -1), -1),
       nullif(greatest(d.b25077_001m::integer, -1), -1),
       nullif(greatest(d.b25064_001e::integer, -1), -1),
       nullif(greatest(d.b25064_001m::integer, -1), -1),
       case when d.b25003_001e::numeric > 0
            then d.b25003_003e::numeric / d.b25003_001e::numeric * 100 end,
       gis.share_moe(d.b25003_003e::numeric, d.b25003_003m::numeric,
                     d.b25003_001e::numeric, d.b25003_001m::numeric),
       case when c.workers > 0 then c.drove_alone / c.workers * 100 end,
       case when c.workers > 0 then c.carpooled / c.workers * 100 end,
       case when c.workers > 0 then c.transit / c.workers * 100 end,
       case when c.workers > 0 then c.walked / c.workers * 100 end,
       case when c.workers > 0 then c.bicycle / c.workers * 100 end,
       case when c.workers > 0 then c.other_mode / c.workers * 100 end,
       case when c.workers > 0 then c.at_home / c.workers * 100 end,
       gis.share_moe(c.at_home, c.at_home_moe, c.workers, c.workers_moe),
       case when c.workers > 0 then c.not_alone / c.workers * 100 end,
       gis.share_moe(c.not_alone, c.not_alone_moe, c.workers, c.workers_moe),
       g.geom
from staging.acs_tract_data_raw d
join commute c on c.geoid = d.geoid
join staging.acs_tract_geom_raw g on g.geoid = d.geoid;
