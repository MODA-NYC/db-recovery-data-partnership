CREATE TEMP TABLE tmp (
    reference_date date,
    county_code text,
    county_name text,
    origin_state text,
    last_14_days_travelers int,
    last_14_days_travelers_sip int,
    last_14_days_travelers_not_sip int,
    travelers_not_sip_daily_miles int
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