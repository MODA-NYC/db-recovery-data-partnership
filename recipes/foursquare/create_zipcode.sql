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
    avgDuration numeric,
    medianDuration text,
    pctTo10Mins numeric,
    pctTo20Mins numeric,
    pctTo30Mins numeric,
    pctTo60Mins numeric,
    pctTo2Hours numeric,
    pctTo4Hours numeric,
    pctTo8Hours numeric,
    pctOver8Hours numeric
);

\COPY tmp FROM PSTDIN WITH NULL AS '' DELIMITER ',' CSV QUOTE '"';

DELETE FROM tmp WHERE categoryid != 'Group';
ALTER TABLE tmp DROP COLUMN categoryid;
UPDATE tmp SET medianDuration=nullif(medianDuration, '')::numeric;

/* Create maintable */
CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT * INTO :NAME.:"VERSION" FROM tmp;

/* Insert records into the Main table */
DELETE FROM :NAME.main WHERE date = :'VERSION';
INSERT INTO :NAME.main SELECT * FROM :NAME.:"VERSION";

COMMIT;