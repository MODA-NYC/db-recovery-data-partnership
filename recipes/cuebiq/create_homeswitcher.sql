BEGIN;

CREATE TEMP TABLE tmp (
    ref_week_code text,
    ref_week_name text,
    new_fips_county varchar(5),
    new_county text,
    old_fips_county varchar(5),
    old_county text,
    home_switcher_pct double precision,
    top10_home_switcher_pct double precision,
    bottom10_home_switcher_pct double precision
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;

SELECT
    REPLACE(ref_week_code, 'W', '') as year_week,
    new_fips_county,
    new_county,
    old_fips_county,
    old_county,
    home_switcher_pct,
    top10_home_switcher_pct,
    bottom10_home_switcher_pct
INTO :NAME.:"VERSION" FROM tmp;

COMMIT;