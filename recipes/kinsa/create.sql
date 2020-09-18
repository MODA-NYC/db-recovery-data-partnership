CREATE TEMP TABLE tmp (
    region_type text,
    region_name text,
    region_state text,
    region_id text,
    signal_type text,
    created_date date,
    pct_ill numeric
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT
    (CASE 
        WHEN a.region_name ~* 'New York' THEN 'MN'
        WHEN a.region_name ~* 'Bronx' THEN 'BX'
        WHEN a.region_name ~* 'Kings' THEN 'BK'
        WHEN a.region_name ~* 'Queens' THEN 'QN'
        WHEN a.region_name ~* 'Richmond' THEN 'SI'
    END) as borough,
    (CASE 
        WHEN a.region_name ~* 'New York' THEN 1
        WHEN a.region_name ~* 'Bronx' THEN 2
        WHEN a.region_name ~* 'Kings' THEN 3
        WHEN a.region_name ~* 'Queens' THEN 4
        WHEN a.region_name ~* 'Richmond' THEN 5
    END) as borocode,
    a.region_id as fips_county,
    a.created_date as date,
    ROUND(a.pct_ill, 2) as pct_ill
INTO :NAME.:"VERSION" 
FROM tmp a;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);