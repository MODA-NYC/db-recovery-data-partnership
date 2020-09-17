# Field-naming Conventions

Below are name and data-type conventions for fields that are common among the RDP datasets

|Field Name|Data Type|Example|Found In|
|----------|---------|--------|-------|
|date|`YYYY-MM-DD`|2020-09-15|cuebiq_cityhall/cuebiq_daily/cuebiq_travelers/foursquare/foursquare_datacube/usl|
|year_week|`IYYY-IW`|2020-35|cuebiq_cityhall/cuebiq_weekly/foursquare_datacube/ioby_donations/opp_insights_*/street_easy/opp_insights_weekly|
|zipcode|`varchar(5)`|10032|foursquare/foursquare_datacube/ioby_count_by_zip/ioby*/oats/upsolve/usl|
|borough|`varchar(2)`|MN|betanyc/opp_insights*/usl|
|location|`text`|NYC, Region, Nation|oats/|
|county|`text`|Kings|cuebiq_cityhall/cuebiq_travelers/kinsa/opp_insights*/|
|fips_county|`varchar(5)`|36001|opp_insights*|
|census_block_group_id|`text`|360470284003|cuebiq_cityhall/|
|state|`varchar(2)`|NY|cuebiq_cityhall/foursquare/kinsa|
|nta_code|`varchar(4)`|MN36|betanyc/street_easy|
|nta_name|`text`|Washington Heights South|betanyc/street_easy|

## Changes needed to standardize
+ `reference_date` -> `date` , and format as `YYYY-MM-DD` in cuebiq_cityhall, cuebiq_daily, cuebiq_travelers
+ `state` as varchar(2) in cuebiq_cityhall, foursquare
+ `date` as `YYYY-MM-DD` in foursquare
+ `county_name` -> `county` in cuebiq_travelers
+ `location` -> `city` in ioby_potential_projects
+ `region_name` -> `county` in kinsa
+ `region_state` -> `state` in kinsa
+ `zip` -> `zipcode` in oats
+ `county_code`-> `fips_county`  in cuebiq_travelers
+ `borough` as varchar(2) in opp_insights_*, usl, and street_easy_rental_sales_index
    + `borough` in street_easy_rental_sales_index contains both borough and NYC. Should there be `location` as in other datasets?
+ `month` -> `date` in street_easy_rental_sales_index (?)
+ `interview_date` -> `date` in upsolve (?)
+ `zip` -> `zipcode` in usl
