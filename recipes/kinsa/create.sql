CREATE TEMP TABLE tmp (
    region_type text,
    region_name text,
    region_state text,
    region_id text,
    signal_type text,
    created_date date,
    percent_ill numeric
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT * INTO :NAME.:"VERSION" FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);