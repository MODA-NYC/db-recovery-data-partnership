CREATE TEMP TABLE tmp (
    reference_date date,
    week_name text,
    county_name text,
    state_name text,
    census_block_group_id text,
    mobility_index numeric,
    weight numeric
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT DISTINCT
    reference_date,
    REPLACE(week_name, 'W', '') as year_week,
    county_name as county,
    state_name as state,
    census_block_group_id,
    ROUND(mobility_index, 8)  as mobility_index,
    weight
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);