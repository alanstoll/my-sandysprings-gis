truncate gis.acs_bg;

with category as (
    select d.geoid, c.name, c.estimate, c.margin,
           row_number() over (partition by d.geoid order by c.estimate desc, c.name) as place
    from staging.acs_bg_data_raw d
    -- B03002's eight categories are mutually exclusive, so ranking them is just ordering a list.
    -- No sentinel handling: unlike the median tables, counts in this one are never suppressed.
    cross join lateral (values
        ('white',       d.b03002_003e::integer, d.b03002_003m::integer),
        ('black',       d.b03002_004e::integer, d.b03002_004m::integer),
        ('aian',        d.b03002_005e::integer, d.b03002_005m::integer),
        ('asian',       d.b03002_006e::integer, d.b03002_006m::integer),
        ('nhpi',        d.b03002_007e::integer, d.b03002_007m::integer),
        ('other',       d.b03002_008e::integer, d.b03002_008m::integer),
        ('multiracial', d.b03002_009e::integer, d.b03002_009m::integer),
        ('hispanic',    d.b03002_012e::integer, d.b03002_012m::integer)
    ) as c(name, estimate, margin)
),
leader as (
    select geoid,
           min(name) filter (where place = 1) as predominant,
           min(name) filter (where place = 2) as runner_up,
           -- Two margins combine as the root of the sum of their squares (ACS handbook); if the
           -- lead is shorter than that, the survey cannot tell these two categories apart.
           (min(estimate) filter (where place = 1) - min(estimate) filter (where place = 2))
               < sqrt(power(min(margin) filter (where place = 1), 2)
                    + power(min(margin) filter (where place = 2), 2)) as ambiguous
    from category
    where place <= 2
    group by geoid
),
-- B01001 is sex by five-year band, so an age group is a sum of bands across both sexes, and its
-- margin is the root of the summed squares of theirs.
age as (
    select d.geoid,
           d.b01001_001e::numeric as people,
           d.b01001_001m::numeric as people_moe,
           d.b01001_003e::numeric + d.b01001_004e::numeric + d.b01001_005e::numeric + d.b01001_006e::numeric + d.b01001_027e::numeric + d.b01001_028e::numeric + d.b01001_029e::numeric + d.b01001_030e::numeric as under_18,
           sqrt(power(d.b01001_003m::numeric, 2) + power(d.b01001_004m::numeric, 2) + power(d.b01001_005m::numeric, 2) + power(d.b01001_006m::numeric, 2) + power(d.b01001_027m::numeric, 2) + power(d.b01001_028m::numeric, 2) + power(d.b01001_029m::numeric, 2) + power(d.b01001_030m::numeric, 2)) as under_18_moe,
           d.b01001_020e::numeric + d.b01001_021e::numeric + d.b01001_022e::numeric + d.b01001_023e::numeric + d.b01001_024e::numeric + d.b01001_025e::numeric + d.b01001_044e::numeric + d.b01001_045e::numeric + d.b01001_046e::numeric + d.b01001_047e::numeric + d.b01001_048e::numeric + d.b01001_049e::numeric as plus_65,
           sqrt(power(d.b01001_020m::numeric, 2) + power(d.b01001_021m::numeric, 2) + power(d.b01001_022m::numeric, 2) + power(d.b01001_023m::numeric, 2) + power(d.b01001_024m::numeric, 2) + power(d.b01001_025m::numeric, 2) + power(d.b01001_044m::numeric, 2) + power(d.b01001_045m::numeric, 2) + power(d.b01001_046m::numeric, 2) + power(d.b01001_047m::numeric, 2) + power(d.b01001_048m::numeric, 2) + power(d.b01001_049m::numeric, 2)) as plus_65_moe
    from staging.acs_bg_data_raw d
),
-- B25044 counts vehicles by tenure, so households with none is owners plus renters
vehicle as (
    select d.geoid,
           d.b25044_001e::numeric as households,
           d.b25044_001m::numeric as households_moe,
           d.b25044_003e::numeric + d.b25044_010e::numeric as none,
           sqrt(power(d.b25044_003m::numeric, 2) + power(d.b25044_010m::numeric, 2)) as none_moe
    from staging.acs_bg_data_raw d
)
insert into gis.acs_bg (geoid, population, white, black, aian, asian, nhpi, other, multiracial,
                        hispanic, predominant, runner_up, ambiguous,
                        age_65_plus, age_65_plus_moe, age_under_18, age_under_18_moe,
                        no_vehicle, no_vehicle_moe, geom)
select d.geoid, d.b03002_001e::integer, d.b03002_003e::integer, d.b03002_004e::integer,
       d.b03002_005e::integer, d.b03002_006e::integer, d.b03002_007e::integer,
       d.b03002_008e::integer, d.b03002_009e::integer, d.b03002_012e::integer,
       l.predominant, l.runner_up, l.ambiguous,
       case when a.people > 0 then a.plus_65 / a.people * 100 end,
       gis.share_moe(a.plus_65, a.plus_65_moe, a.people, a.people_moe),
       case when a.people > 0 then a.under_18 / a.people * 100 end,
       gis.share_moe(a.under_18, a.under_18_moe, a.people, a.people_moe),
       case when v.households > 0 then v.none / v.households * 100 end,
       gis.share_moe(v.none, v.none_moe, v.households, v.households_moe),
       g.geom
from staging.acs_bg_data_raw d
join leader l on l.geoid = d.geoid
join age a on a.geoid = d.geoid
join vehicle v on v.geoid = d.geoid
join staging.acs_bg_geom_raw g on g.geoid = d.geoid;
