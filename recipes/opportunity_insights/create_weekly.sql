CREATE TEMP TABLE tmp (
    year text,
    month text,
    day_endofweek text,
    fipscounty text,
    engagement numeric,
    badges numeric,
    break_engagement numeric,
    break_badges numeric,
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
        CONCAT_WS('-',year,LPAD(month,2,'0'),LPAD(day_endofweek,2,'0'))::date, 
        'IYYY-IW') as year_week,
    SUM(initial_claims) as ui_claims,
    SUM(initial_claims_rate) as ui_claims_rate,
    SUM(engagement) as zearn_engagement,
    SUM(badges) as zearn_badges
INTO :NAME.:"VERSION"
FROM tmp
GROUP BY fipscounty, county, year_week
ORDER BY fips_county, year_week;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);