CREATE TEMP TABLE tmp (
    fipscounty text,
    year text,
    month text,
    day_endofweek text,
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
        WHEN fipscounty ~* '9' THEN 'CT'
        WHEN fipscounty ~* '34' THEN 'NJ'
        WHEN fipscounty ~* '36' THEN 'NY'
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
    fipscounty as fips_county, 
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