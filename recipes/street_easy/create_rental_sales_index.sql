CREATE TEMP TABLE tmp(
    month date,
    borough text,
    submarket text,
    sales_index numeric,
    rental_index numeric
);


\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

-- Create table containing both boro and submarket-level data
CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT
    to_char(month::date, 'IYYY-MM') as year_month,
        (CASE
        WHEN borough = 'Queens' THEN 'QN'
        WHEN borough = 'Staten Island' THEN 'SI'
        WHEN borough = 'Manhattan' THEN 'MN'
        WHEN borough = 'Bronx' THEN 'BX'
        WHEN borough = 'Brooklyn' THEN 'BK'
        ELSE borough
    END) as borough,
    (CASE
        WHEN borough = 'Queens' THEN 4
        WHEN borough = 'Staten Island' THEN 5
        WHEN borough = 'Manhattan' THEN 1
        WHEN borough = 'Bronx' THEN 2
        WHEN borough = 'Brooklyn' THEN 3
    END) as borocode,
    submarket,
    sales_index,
    rental_index
INTO :NAME.:"VERSION"
FROM tmp;

-- Create view containing just submarkets
DROP VIEW IF EXISTS :NAME.monthly_rental_sales_index_submkt;
CREATE VIEW :NAME.monthly_rental_sales_index_submkt AS (
    SELECT * 
    FROM :NAME.:"VERSION"
    WHERE submarket NOT IN ('Queens', 'Staten Island', 'Manhattan', 'Bronx', 'Brooklyn', 'NYC')
); 

-- Create view containing boroughs and NYC
DROP VIEW IF EXISTS :NAME.monthly_rental_sales_index_boro;
CREATE VIEW :NAME.monthly_rental_sales_index_boro AS (
    SELECT
        year_month,
        borough,
        borocode,
        sales_index,
        rental_index
    FROM :NAME.:"VERSION"
    WHERE submarket IN ('Queens', 'Staten Island', 'Manhattan', 'Bronx', 'Brooklyn', 'NYC')
); 