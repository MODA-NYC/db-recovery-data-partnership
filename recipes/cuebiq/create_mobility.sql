BEGIN;

CREATE TEMP TABLE tmp (
    date date,
    week_name text,
    county_name text,
    state_name text,
    cbg2010 text,
    mobility_index numeric,
    weight numeric
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT DISTINCT
    date,
    REPLACE(week_name, 'W', '') as year_week,
    (CASE
        WHEN county_name = 'Queens' THEN 'QN'
        WHEN county_name = 'Richmond (Staten Island)' THEN 'SI'
        WHEN county_name = 'New York (Manhattan)' THEN 'MN'
        WHEN county_name = 'Bronx' THEN 'BX'
        WHEN county_name = 'Kings(Brooklyn)' THEN 'BK'
    END) as borough,
    (CASE
        WHEN county_name = 'Queens' THEN 4
        WHEN county_name = 'Richmond (Staten Island)' THEN 5
        WHEN county_name = 'New York (Manhattan)' THEN 1
        WHEN county_name = 'Bronx' THEN 2
        WHEN county_name = 'Kings(Brooklyn)' THEN 3
    END) as borocode,
    cbg2010,
    ROUND(mobility_index, 8)  as mobility_index,
    weight
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);

COMMIT;