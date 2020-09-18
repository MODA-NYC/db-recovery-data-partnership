# Field-naming Conventions

Below are name and data-type conventions for fields that are common among the RDP datasets

|Field Name|Data Type|Example|Found In|
|----------|---------|--------|-------|
|date|`YYYY-MM-DD`|2020-09-15|cuebiq_cityhall/cuebiq_daily/cuebiq_travelers/foursquare/foursquare_datacube/usl|
|year_week|`IYYY-IW`|2020-35|cuebiq_cityhall/cuebiq_weekly/foursquare_datacube/ioby_donations/opp_insights_*/street_easy/opp_insights_weekly|
|zipcode|`varchar(5)`|10032|foursquare/foursquare_datacube/ioby_count_by_zip/ioby*/oats/upsolve/usl|
|borough|`varchar(2)`|MN|betanyc/opp_insights*/usl|
|location|`text`|NYC, Region, Nation|oats/opp_insights*|
|county|`text`|Kings|cuebiq_cityhall/cuebiq_travelers/kinsa/opp_insights*/|
|fips_county|`varchar(5)`|36001|opp_insights*|
|cbg2010|`text`|360470284003|cuebiq_cityhall/|
|~~bctcb2010~~|`text`|||
|~~ct2010~~|`text`|||
|council| `numeric`|||
|borocd|`numeric`|401||
|borocode|`numeric`|4||
|~~boroname~~|`numeric`||Staten Island|
|address|`text`|120 Broadway|betanyc|
|state|`varchar(2)`|NY|cuebiq_cityhall/foursquare/kinsa|
|ntacode|`varchar(4)`|MN36|betanyc/street_easy|
|latitude|`double precision`|40.725038|betanyc|
|longitude|`double precision`|-73.956633|betanyc|
|income|`text`|$25,001-$50,000|oats|



If a file is NYC specific and contains information at the county level or lower, make sure that it has the field `borough`
