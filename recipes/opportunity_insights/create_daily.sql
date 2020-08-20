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
    gps_resitential numeric,
    gps_away_from_home numeric,
    merchants_all numeric,
    revenue_all numeric,
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
    county_name as county,
    (CASE 
        WHEN fipscounty = '36005' THEN 'Bronx'
        WHEN fipscounty = '36047' THEN 'Brooklyn'
        WHEN fipscounty = '36061' THEN 'Manhattan'
        WHEN fipscounty = '36081' THEN 'Queens'
        WHEN fipscounty = '36085' THEN 'Staten Island'
        ELSE NULL
    END) as borough,
    fipscounty,
    CONCAT_WS('-',year,LPAD(month,2,'0'),LPAD(day,2,'0'))::date AS date,
    spend_all,
    gps_retail_and_recreation,
    gps_grocery_and_pharmacy,
    gps_parks,
    gps_transit_stations,
    gps_workplaces,
    gps_resitential,
    gps_away_from_home,
    merchants_all,
    revenue_all
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);
