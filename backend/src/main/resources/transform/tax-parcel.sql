truncate gis.tax_parcel;

insert into gis.tax_parcel (parcel_id, address, land_use_code, class_code, acres, living_units, category, geom)
select parcelid, address, lucode, classcode, landacres, livunits,
       -- Fulton publishes 116 land use codes in this city alone, which is too fine to colour a map
       -- by and has no description table in the download. This is the coarse grouping behind them.
       --
       -- 101, 106 and 107 are the county's own definitions -- Residential 1 family, Single Family
       -- Residential Condominium, Single Family Residential Townhouse -- and cover 92% of parcels.
       -- The 600s are likewise the county's: 610 Recreation/Health, 611 Library, 612 School, 613
       -- College, 620-622 Religious. The rest is read off the digest, where the first digit of the
       -- land use code and the letter of the class code agree almost perfectly: every 1xx is class
       -- R, every 2xx and 3xx class C, every 6xx class E, every 7xx class U.
       --
       -- 110 joins the condominium group on its footprint: like 106 and 107 it averages three
       -- hundredths of an acre and exactly one dwelling, which is an individually owned unit rather
       -- than a lot. The remaining 1xx codes hold 874 parcels carrying 56 dwellings between them,
       -- so they are land rather than housing, and are grouped as such.
       case
           when lucode in ('106', '107', '110') then 'condo_townhouse'
           when lucode in ('101', '102', '103') then 'single_family'
           when lucode like '1%' then 'residential_other'
           when lucode like '2%' or lucode like '8%' then 'multifamily'
           when left(classcode, 1) = 'I' then 'industrial'
           when lucode like '6%' then 'institutional'
           when lucode like '7%' then 'utility'
           else 'commercial'
       end,
       geom
from staging.tax_parcel_raw;
