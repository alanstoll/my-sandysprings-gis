truncate gis.tax_parcel;

insert into gis.tax_parcel (parcel_id, address, land_use_code, class_code, acres, living_units, geom)
select parcelid, address, lucode, classcode, landacres, livunits, geom
from staging.tax_parcel_raw;
