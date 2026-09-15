-- A coarse class to colour the map by, derived in transform/tax-parcel.sql from the county's land
-- use code; see StagingTransformer. gis.tax_parcel is a pure derivative of staging and is rebuilt on
-- every start, so emptying it here costs nothing and lets the column be not null from the outset.
truncate gis.tax_parcel;

alter table gis.tax_parcel add column category text not null;
