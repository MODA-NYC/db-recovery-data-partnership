CREATE TEMP TABLE tmp (
    fipscounty text,
    year text,
    month text,
    day_endofweek text,
    engagement numeric,
    badges numeric,
    imputed_from_cz boolean,
    initial_claims numeric,
    initial_claims_rate numeric,
    county_name text
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

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
    TO_CHAR(
        CONCAT_WS('-',year,LPAD(month,2,'0'),LPAD(day_endofweek,2,'0'))::date, 
        'IYYY-IW') as year_week,
    fipscounty,
    initial_claims as ui_claims,
    initial_claims_rate as ui_claims_rate,
    engagement as zearn_engagement,
    badges as zearn_badges
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);