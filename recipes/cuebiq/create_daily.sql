BEGIN;

CREATE TEMP TABLE automotive (
    date date,
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
DELETE FROM automotive WHERE market_area_code != '501';

CREATE TEMP TABLE dining (
    date date,
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
DELETE FROM dining WHERE market_area_code != '501';


CREATE TEMP TABLE healthcare (
    date date,
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
DELETE FROM healthcare WHERE market_area_code != '501';

CREATE TEMP TABLE lifestyle (
    date date,
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
DELETE FROM lifestyle WHERE market_area_code != '501';

CREATE TEMP TABLE malls (
    date date,
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
DELETE FROM malls WHERE market_area_code != '501';

CREATE TEMP TABLE retail (
    date date,
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
DELETE FROM retail WHERE market_area_code != '501';

CREATE TEMP TABLE telco (
    date date,
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
DELETE FROM telco WHERE market_area_code != '501';

CREATE TEMP TABLE transportation (
    date date,
    market_area_code text,
    market_area text,
    sector text,
    vertical text,
    roll_avg_7days_cvi numeric,
    ly_roll_avg_7days_cvi numeric,
    roll_avg_7days_cvi_per_store numeric,
    ly_roll_avg_7days_cvi_per_store numeric
);

\COPY transportation FROM PROGRAM 'gzip -dc input/daily-cvi-transportation.csv000.gz' DELIMITER ',' CSV HEADER;
DELETE FROM transportation WHERE market_area_code != '501';

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
WITH all_sectors AS (
    (SELECT * FROM automotive WHERE market_area_code = '501') UNION
    (SELECT * FROM dining WHERE market_area_code = '501') UNION
    (SELECT * FROM healthcare WHERE market_area_code = '501') UNION
    (SELECT * FROM lifestyle WHERE market_area_code = '501') UNION
    (SELECT * FROM malls WHERE market_area_code = '501') UNION
    (SELECT * FROM retail WHERE market_area_code = '501') UNION
    (SELECT * FROM telco WHERE market_area_code = '501') UNION
    (SELECT 
        date, 
        market_area_code, 
        market_area,sector, 
        vertical,
        NULL::text as brand,
        NULL::text as naics6_code,
        roll_avg_7days_cvi,
        ly_roll_avg_7days_cvi,
        roll_avg_7days_cvi_per_store,
        ly_roll_avg_7days_cvi_per_store
    FROM transportation WHERE market_area_code = '501')
)
SELECT 
    date,
    to_char(date::date, 'IYYY-IW') as year_week,
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

COMMIT;
