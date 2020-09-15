# Field-naming Conventions

Below are name and data-type conventions for fields that are common among the RDP datasets

|Field Name|Data Type|Example|Found In|
|----------|---------|--------|-------|
|date|`YYYY-MM-DD`|2020-09-15|cuebiq_cityhall/cuebiq_daily/cuebiq_travelers/foursquare/foursquare_datacube|
|year_week|`IYYY-IW`|2020-35|cuebiq_cityhall/cuebiq_weekly/ioby_donations|
|zipcode|`varchar(5)`|10032|foursquare/foursquare_datacube/ioby_count_by_zip/ioby|
|borough|`varchar(2)`|MN|betanyc/ |
|location|`text`|NYC, region, nation||
|county|`text`|Sullivan|cuebiq_cityhall/|
|county_code|`varchar(5)`|36001|cuebiq_travelers|
|census_block_group_id|`text`|360470284003|cuebiq_cityhall/|
|state|`varchar(2)`|NY|cuebiq_cityhall/foursquare/|
|nta_code|`text`|||

## Changes needed to standardize
+ `reference_date` -> `date` , and format as `YYYY-MM-DD` in cuebiq_cityhall, cuebiq_daily, cuebiq_travelers
+ `state` as varchar(2) in cuebiq_cityhall, foursquare
+ `date` as `YYYY-MM-DD` in foursquare
+ `county_name` -> `county` in cuebiq_travelers
+ `location` -> `city` in ioby_potential_projects
