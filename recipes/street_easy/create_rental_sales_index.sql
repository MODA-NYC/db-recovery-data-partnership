CREATE TEMP TABLE tmp(
    month date,
    borough text,
    sales_index numeric,
    rental_index numeric
);


\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

-- Join with NTA geometry and round
CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT *
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
); 