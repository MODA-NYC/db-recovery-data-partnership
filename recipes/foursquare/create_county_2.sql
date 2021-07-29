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
    data_date date,
    country text,
    state text,
    county text,
    zip text,
    categoryid text,
    categoryname text,
    hour text,
    demo text,
    visits text,
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

--DELETE FROM tmp WHERE categoryid != 'Group';

--ALTER TABLE tmp 


/* Create maintable */
CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT 
    data_date,
    to_char(data_date::date, 'IYYY-IW') as year_week,
    country,
    state,
    county,
    (CASE 
           WHEN county = 'Bronx' AND state = 'New York' THEN 'BX'
           WHEN county = 'Kings' AND state = 'New York' THEN 'BK'
           WHEN county = 'New York' AND state = 'New York' THEN 'MN'
           WHEN county = 'Queens' AND state = 'New York' THEN 'QN'
           WHEN county = 'Richmond' AND state = 'New York' THEN 'SI'
           ELSE ''
       END) as borough,
    (CASE    
           WHEN county = 'Bronx' AND state = 'New York' THEN 2
           WHEN county = 'Kings' AND state = 'New York' THEN 3
           WHEN county = 'New York' AND state = 'New York' THEN 1
           WHEN county = 'Queens' AND state = 'New York' THEN 4
           WHEN county = 'Richmond' AND state = 'New York' THEN 5
           ELSE 0
       END) as borocode,
    categoryname,
    hour,
    demo,
    nullif(visits, '')::numeric AS visits,
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
INTO :NAME.:"VERSION" FROM tmp
WHERE state = 'New York' AND county IN ('Bronx', 'Kings', 'New York', 'Queens', 'Richmond'); 

DROP TABLE IF EXISTS :NAME.daily_county CASCADE;
SELECT
    data_date,
    country,
    state,
    county,
    borough,
    borocode,
    categoryname,
    visits,
    avgDuration,
    medianDuration,
    pctTo10Mins,
    pctTo20Mins,
    pctTo30Mins,
    pctTo60Mins,
    pctTo2Hours,
    pctTo4Hours,
    pctTo8Hours,
    pctOver8Hours
INTO :NAME.daily_county
FROM :NAME.:"VERSION";



DROP TABLE IF EXISTS :NAME.weekly_county CASCADE;
SELECT 
    year_week,
    country,
    state,
    county,
    borough,
    borocode,
    categoryname,
    SUM(visits) as visits,
    AVG(avgDuration) as avgDuration,
    AVG(medianDuration) as medianDuration,
    AVG(pctTo10Mins) as pctTo10Mins,
    AVG(pctTo20Mins) as pctTo20Mins,
    AVG(pctTo30Mins) as pctTo30Mins,
    AVG(pctTo60Mins) as pctTo60Mins,
    AVG(pctTo2Hours) as pctTo2Hours,
    AVG(pctTo4Hours) as pctTo4Hours,
    AVG(pctTo8Hours) as pctTo8Hours,
    AVG(pctOver8Hours) as pctOver8Hours
INTO :NAME.weekly_county
FROM :NAME.:"VERSION"
GROUP BY year_week, country, state, county, borough, borocode, categoryname;   


DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :"VERSION" as v, * 
    FROM :NAME.:"VERSION"
    );
END TRANSACTION;
-- Need to commit weekly_county before the function if_version_valid_make_weekly
BEGIN;
/* Insert records into the Main tables */
--First the daily data
DELETE FROM :NAME.main_county_daily WHERE data_date = :'VERSION';
INSERT INTO :NAME.main_county_daily 
    SELECT * FROM :NAME.daily_county;

--receiving bad version data such as '1989' that break naming conventions and preventing a cast to date to extract the week component.

CREATE function if_version_valid_make_weekly(v text, n text)
   RETURNS int 
   language plpgsql
AS
$$
BEGIN
    IF LENGTH(v) = 10 THEN
        DELETE FROM foursquare_county.main_county_weekly WHERE  year_week = to_char(v::date, 'IYYY-IW');
        INSERT INTO foursquare_county.main_county_weekly 
            SELECT * FROM foursquare_county.weekly_county;
        
        RETURN 0;
    END IF;
RETURN 1;
END $$;

--Call function.
SELECT if_version_valid_make_weekly( v => :'VERSION', n => :'NAME');
--Drop the function. It will be re-defined every time the script runs.
DROP function if_version_valid_make_weekly;
END TRANSACTION;


