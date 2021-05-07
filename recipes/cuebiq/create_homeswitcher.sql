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
INTO :NAME.:"VERSION" FROM tmp
WHERE new_fips_county IN ('36047'
,'36081'
,'36061'
,'36005'
,'36085'
,'36119'
,'34003'
,'34017'
,'34031'
,'36079'
,'36087'
,'36103'
,'36059'
,'34023'
,'34025'
,'34029'
,'34035'
,'34013'
,'34039'
,'34027'
,'34037'
,'34019'
,'42103'
,'09001'
,'09009'
,'34021'
,'09005'
,'36111'
,'39111'
,'36027'
,'36071'
)

OR old_fips_county IN ('36047'
,'36081'
,'36061'
,'36005'
,'36085'
,'36119'
,'34003'
,'34017'
,'34031'
,'36079'
,'36087'
,'36103'
,'36059'
,'34023'
,'34025'
,'34029'
,'34035'
,'34013'
,'34039'
,'34027'
,'34037'
,'34019'
,'42103'
,'09001'
,'09009'
,'34021'
,'09005'
,'36111'
,'39111'
,'36027'
,'36071'
);

COMMIT;