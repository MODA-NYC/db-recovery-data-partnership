CREATE TEMP TABLE tmp(
    month date,
    borough text,
    sales_index numeric,
    rental_index numeric
);


\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

-- Join with NTA geometry and round
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
    sales_index,
    rental_index
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
); 