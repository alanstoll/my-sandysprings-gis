truncate gis.city_limit_inhouse;

-- The City's published boundary is the 2005 incorporation geometry and has never been revised. It
-- sits about 250 ft west of the Fulton County parcel fabric the city is actually assessed on: only
-- 6.3% of it comes within 25 ft of a parcel line, its median distance to one is 182 ft, and it
-- leaves 177 Sandy Springs parcels wholly outside the city. This moves it back.
--
-- The offset is pinned to one surveyed corner rather than fitted over the whole ring: the point
-- where parcels 17 0023  LL0214 and 06 038400012040 meet off Weldstone Terrace, which the city
-- limit turns on and which the two parcels agree to the inch about. That lands the corner to within
-- 0.006 ft, takes the median distance to 112 ft, and leaves 2 parcels outside rather than 177.
--
-- A fitted translation was the alternative and is not better: the best one over the whole ring
-- (260 ft east, 60 ft north) differs from this by less than a lot's width, scores the same within
-- 50 ft, and has no control point behind it. Neither is the whole answer, because the offset is not
-- rigid -- let 8,000 ft tiles each choose their own translation and 13 of 24 land 80% or more of
-- their stretch on a parcel line, but the eastward component runs from about 300 ft in the west to
-- 200 ft in the east. Closing that last ~100 ft needs an affine fit, not a shift.
--
-- EPSG:2240 is the county's own working CRS and its unit is the US survey foot, so dx_ft and dy_ft
-- are feet with no conversion.
insert into gis.city_limit_inhouse (name, dx_ft, dy_ft, geom)
select name, 253.46, 41.01,
       st_multi(st_transform(st_translate(st_transform(geom, 2240), 253.46, 41.01), 4326))
from gis.city_limit;
