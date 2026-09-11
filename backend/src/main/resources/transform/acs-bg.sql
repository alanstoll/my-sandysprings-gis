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
)
insert into gis.acs_bg (geoid, population, white, black, aian, asian, nhpi, other, multiracial,
                        hispanic, predominant, runner_up, ambiguous, geom)
select d.geoid, d.b03002_001e::integer, d.b03002_003e::integer, d.b03002_004e::integer,
       d.b03002_005e::integer, d.b03002_006e::integer, d.b03002_007e::integer,
       d.b03002_008e::integer, d.b03002_009e::integer, d.b03002_012e::integer,
       l.predominant, l.runner_up, l.ambiguous, g.geom
from staging.acs_bg_data_raw d
join leader l on l.geoid = d.geoid
join staging.acs_bg_geom_raw g on g.geoid = d.geoid;
