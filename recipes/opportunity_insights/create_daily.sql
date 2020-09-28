CREATE TEMP TABLE tmp (
    fipscounty text,
    year text,
    month text,
    day text,
    spend_all numeric,
    gps_retail_and_recreation numeric,
    gps_grocery_and_pharmacy numeric,
    gps_parks numeric,
    gps_transit_stations numeric,
    gps_workplaces numeric,
    gps_residential numeric,
    gps_away_from_home numeric,
    --merchants_all numeric,
    --revenue_all numeric,
    county_name text
);

\COPY tmp FROM PSTDIN DELIMITER '|' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT
    (CASE 
        WHEN fipscounty IN ('36005','36047','36061','36081','36085')
            THEN 'NYC'
        ELSE 'Region'
    END) as location,
    SPLIT_PART(county_name, ' County', 1) as county,
    (CASE
        WHEN LEFT(fipscounty, 1) = '9' THEN 'CT'
        WHEN LEFT(fipscounty, 2) = '34' THEN 'NJ'
        WHEN LEFT(fipscounty, 2) = '36' THEN 'NY'
    END) as state,
    (CASE 
        WHEN fipscounty = '36005' THEN 'BX'
        WHEN fipscounty = '36047' THEN 'BK'
        WHEN fipscounty = '36061' THEN 'MN'
        WHEN fipscounty = '36081' THEN 'QN'
        WHEN fipscounty = '36085' THEN 'SI'
        ELSE NULL
    END) as borough,
    (CASE 
        WHEN fipscounty = '36005' THEN 2
        WHEN fipscounty = '36047' THEN 3
        WHEN fipscounty = '36061' THEN 1
        WHEN fipscounty = '36081' THEN 4
        WHEN fipscounty = '36085' THEN 5
        ELSE NULL
    END) as borocode,
    LPAD(fipscounty, 5, '0') as fips_county,
    TO_CHAR(
        CONCAT_WS('-',year,LPAD(month,2,'0'),LPAD(day,2,'0'))::date, 
        'IYYY-IW') as year_week,
    CONCAT_WS('-',year,LPAD(month,2,'0'),LPAD(day,2,'0'))::date AS date,
    spend_all,
    gps_retail_and_recreation,
    gps_grocery_and_pharmacy,
    gps_parks,
    gps_transit_stations,
    gps_workplaces,
    gps_residential,
    gps_away_from_home
    --merchants_all,
    --revenue_all
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);
