BEGIN;
CREATE TEMP TABLE tmp(
    year_month date,
    borough text,
    borocode numeric,
    submarket text,
    sales_index numeric,
    rental_index numeric
);


\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

-- Join with NTA geometry and round
-- Steve: What geometery?
CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT
    to_char(year_month::date, 'IYYY-MM') as year_month,
    borough,
    borocode,
    submarket,
    sales_index,
    rental_index
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.streeteasy_monthly_rental_sales_index_submkt; 
CREATE VIEW :NAME.streeteasy_monthly_rental_sales_index_submkt AS (
    SELECT year_month, borough, borocode, submarket, sales_index, rental_index
    FROM :NAME.:"VERSION"
    WHERE (submarket <> 'Manhattan'
     AND submarket <> 'Bronx'
     AND submarket <> 'Brooklyn'
     AND submarket <> 'Queens'
     AND submarket <> 'Staten Island'
     AND submarket <> 'NYC')
);

DROP VIEW IF EXISTS :NAME.streeteasy_monthly_rental_sales_index_boro;
CREATE VIEW  :NAME.streeteasy_monthly_rental_sales_index_boro AS (
    SELECT *
    FROM :NAME.:"VERSION"
    WHERE (submarket = 'Manhattan'
     OR submarket = 'Bronx'
     OR submarket = 'Brooklyn'
     OR submarket = 'Queens'
     OR submarket = 'Staten Island')
);

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
); 
COMMIT;
