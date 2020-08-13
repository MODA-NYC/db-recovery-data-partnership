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

\COPY tmp FROM PPROGRAM 'gzip -dc input/daily-cvi-automotive.csv000.gz' DELIMITER ',' CSV HEADER;

-- \COPY tmp FROM PSTDIN DELIMITER ',' CSV QUOTE '"';

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