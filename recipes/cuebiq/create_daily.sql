CREATE TEMP TABLE automotive (
    reference_date text,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    brand text,
    naics6_code text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric,
    roll_avg_7days_cvi_per_store numeric,
    ly_roll_avg_7days_cvi_per_store numeric
);

\COPY automotive FROM PROGRAM 'gzip -dc input/daily-cvi-automotive.csv000.gz' DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE dining (
    reference_date text,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    brand text,
    naics6_code text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric,
    roll_avg_7days_cvi_per_store numeric,
    ly_roll_avg_7days_cvi_per_store numeric
);

\COPY dining FROM PROGRAM 'gzip -dc input/daily-cvi-dining.csv000.gz' DELIMITER ',' CSV HEADER;


CREATE TEMP TABLE healthcare (
    reference_date text,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    brand text,
    naics6_code text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric,
    roll_avg_7days_cvi_per_store numeric,
    ly_roll_avg_7days_cvi_per_store numeric
);

\COPY healthcare FROM PROGRAM 'gzip -dc input/daily-cvi-healthcare.csv000.gz' DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE lifestyle (
    reference_date text,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    brand text,
    naics6_code text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric,
    roll_avg_7days_cvi_per_store numeric,
    ly_roll_avg_7days_cvi_per_store numeric
);

\COPY lifestyle FROM PROGRAM 'gzip -dc input/daily-cvi-lifestyle.csv000.gz' DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE malls (
    reference_date text,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    brand text,
    naics6_code text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric,
    roll_avg_7days_cvi_per_store numeric,
    ly_roll_avg_7days_cvi_per_store numeric
);

\COPY malls FROM PROGRAM 'gzip -dc input/daily-cvi-malls.csv000.gz' DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE retail (
    reference_date text,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    brand text,
    naics6_code text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric,
    roll_avg_7days_cvi_per_store numeric,
    ly_roll_avg_7days_cvi_per_store numeric
);

\COPY retail FROM PROGRAM 'gzip -dc input/daily-cvi-retail.csv000.gz' DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE telco (
    reference_date text,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    brand text,
    naics6_code text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric,
    roll_avg_7days_cvi_per_store numeric,
    ly_roll_avg_7days_cvi_per_store numeric
);

\COPY telco FROM PROGRAM 'gzip -dc input/daily-cvi-telco.csv000.gz' DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE transportation (
    reference_date text,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    brand text,
    naics6_code text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric
);

\COPY transportation FROM PROGRAM 'gzip -dc input/daily-cvi-transportation.csv000.gz' DELIMITER ',' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
WITH all_sectors AS (
    (SELECT * FROM automotive) UNION
    (SELECT * FROM dining) UNION
    (SELECT * FROM healthcare) UNION
    (SELECT * FROM lifestyle) UNION
    (SELECT * FROM malls) UNION
    (SELECT * FROM retail) UNION
    (SELECT * FROM telco) UNION
    (SELECT *, 
        NULL::numeric as roll_avg_7days_cvi_per_store,
        NULL::numeric as ly_roll_avg_7days_cvi_per_store
    FROM transportation)
)
SELECT 
    reference_date,
    to_char(reference_date::date, 'IYYY-IW') as year_week,
    market_area_code,
    market_area,
    sector,
    vertical,
    brand,
    naics6_code,
    ROUND(roll_avg_7days_cvi, 4) as roll_avg_7days_cvi,
    ROUND(ly_roll_avg_7days_cvi, 4) as ly_roll_avg_7days_cvi,
    ROUND(roll_avg_7days_cvi_per_store, 4) as roll_avg_7days_cvi_per_store,
    ROUND(ly_roll_avg_7days_cvi_per_store, 4) as ly_roll_avg_7days_cvi_per_store
INTO :NAME.:"VERSION"
FROM all_sectors;

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