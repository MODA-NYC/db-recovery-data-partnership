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
SELECT DISTINCT *
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);