BEGIN;

CREATE TEMP TABLE tmp (
    ref_week_code text,
    ref_week_name text,
    new_county_fips varchar(5),
    new_county_name text,
    old_county_fips varchar(5),
    old_county_name text,
    home_switcher_pct double precision,
    top10_home_switcher_pct double precision,
    bottom10_home_switcher_pct double precision
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;

SELECT
    REPLACE(ref_week_code, 'W', '') as year_week,
    new_county_fips,
    new_county_name,
    old_county_fips,
    old_county_name,
    home_switcher_pct,
    top10_home_switcher_pct,
    bottom10_home_switcher_pct
INTO :NAME.:"VERSION" FROM tmp;

DROP TABLE IF EXISTS :NAME.region_inflow;
CREATE TABLE :NAME.region_inflow AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
    WHERE new_county_fips in 
    ('09001','09005','9009','34003','34013',
    '34017','34019','34021','34023','34025',
    '34027','34029','34031','34035','34037',
    '34039','34041','36005','36027','36047',
    '36059','36061','36071','36079','36081',
    '36085','36087','36103','36105','36111','36119')
);

DROP TABLE IF EXISTS :NAME.region_outflow;
CREATE TABLE :NAME.region_outflow AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
    WHERE old_county_fips in 
    ('09001','09005','9009','34003','34013',
    '34017','34019','34021','34023','34025',
    '34027','34029','34031','34035','34037',
    '34039','34041','36005','36027','36047',
    '36059','36061','36071','36079','36081',
    '36085','36087','36103','36105','36111','36119')
);

DROP TABLE IF EXISTS :NAME.nyc_inflow;
CREATE TABLE :NAME.nyc_inflow AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
    WHERE new_county_fips in 
    ('36085','36081','36061','36047','36005')
);

DROP TABLE IF EXISTS :NAME.nyc_outflow;
CREATE TABLE :NAME.nyc_outflow AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
    WHERE old_county_fips in 
    ('36085','36081','36061','36047','36005')
);

COMMIT;
