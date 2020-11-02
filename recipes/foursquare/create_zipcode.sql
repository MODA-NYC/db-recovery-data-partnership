/*
Cube Dimension Keys:
dt - date in YYYY-MM-DD format
country - ISO country code (data should be provided for US only)
state - State + DC
county - county
zip - zipcode
categoryid - foursquare category ID or 'Group' placeholder for special groupings
categoryname - category name or group name + overall rollup
hour - hour of day of visits + overall rollup
demo - demographic group of visitors + overall rollup

Data:
visits - normalized visitors
avgDuration - average linger time of visitors
medianDuration - 50th percentile linger time of visitors
pctTo10Mins - normalized visitors lingering < 10 minutes
pctTo20Mins - normalized visitors lingering > 10 and < 20 minutes
pctTo30Mins - normalized visitors lingering > 20 and < 30 minutes
pctTo60Mins - normalized visitors lingering > 30 and < 60 minutes
pctTo2Hours - normalized visitors lingering > 1 and < 2 hours
pctTo4Hours - normalized visitors lingering > 2 and < 4 hours
pctTo8Hours - normalized visitors lingering > 4 and < 8 hours
pctOver8Hours - normalized visitors lingering more than 8 hours

Time of Day Definitions:

Morning: 6am to 8:59am
Late Morning: 9am to 11:59am
Early Afternoon: 12pm to 2:59pm
Late Afternoon: 3pm to 4:59pm
Evening: 5pm to 7:59pm
Late Evening: 8pm to 10:59pm
Night: 11pm to 2:59am
Late Night: 3am to 5:59am
*/
BEGIN;

CREATE TEMP TABLE tmp (
    date date,
    country text,
    state text,
    county text,
    zip text,
    categoryid text,
    categoryname text,
    hour text,
    demo text,
    visits numeric,
    avgDuration text,
    medianDuration text,
    pctTo10Mins text,
    pctTo20Mins text,
    pctTo30Mins text,
    pctTo60Mins text,
    pctTo2Hours text,
    pctTo4Hours text,
    pctTo8Hours text,
    pctOver8Hours text
);

\COPY tmp FROM PSTDIN WITH NULL AS '' DELIMITER ',' CSV;

DELETE FROM tmp WHERE categoryid != 'Group';
ALTER TABLE tmp 
    DROP COLUMN categoryid,
    DROP COLUMN country,
    DROP COLUMN state,
    DROP COLUMN county;
DELETE FROM tmp WHERE zip not in (select distinct zipcode from city_zip_boro);

/* Create maintable */
CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT 
    date,
    zip,
    categoryname,
    hour,
    demo,
    visits,
    nullif(avgDuration, '')::numeric AS avgDuration,
    nullif(medianDuration, '')::numeric AS medianDuration,
    nullif(pctTo10Mins, '')::numeric AS pctTo10Mins,
    nullif(pctTo20Mins, '')::numeric AS pctTo20Mins,
    nullif(pctTo30Mins, '')::numeric AS pctTo30Mins,
    nullif(pctTo60Mins, '')::numeric AS pctTo60Mins,
    nullif(pctTo2Hours, '')::numeric AS pctTo2Hours,
    nullif(pctTo4Hours, '')::numeric AS pctTo4Hours,
    nullif(pctTo8Hours, '')::numeric AS pctTo8Hours,
    nullif(pctOver8Hours, '')::numeric AS pctOver8Hours
INTO :NAME.:"VERSION" FROM tmp;

/* Insert records into the Main table */
DELETE FROM :NAME.main WHERE date = :'VERSION';
INSERT INTO :NAME.main SELECT * FROM :NAME.:"VERSION";

COMMIT;
