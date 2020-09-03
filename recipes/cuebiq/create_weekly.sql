CREATE TEMP TABLE tmp (
    visit_week_cd text,
    week_label text,
    market_area_code text,
    market_area text,
    brand text,
    vertical text,
    sector text,
    cvi numeric,
    cvi_per_store numeric
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV QUOTE '"';

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT 
    REPLACE(visit_week_cd, 'W', '') as year_week,
    market_area_code,
    market_area,
    sector,
    vertical,
    brand,
    ROUND(cvi, 4) as cvi,
    ROUND(cvi_per_store, 4) as cvi
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);

DROP VIEW IF EXISTS :NAME.nyc_latest;
CREATE VIEW :NAME.nyc_latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
    WHERE market_area_code = '501'
);