CREATE TEMP TABLE tmp (
    date timestamp,
    state text,
    borough text,
    categoryid text,
    categoryname text,
    demo text,
    visits double precision,
    avgDuration double precision,
    p50Duration double precision
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

UPDATE tmp
SET borough = 
    (CASE 
        WHEN borough = 'Bronx County' THEN 'BX'
        WHEN borough = 'Brooklyn' THEN 'BK'
        WHEN borough = 'New York' THEN 'MN'
        WHEN borough = 'Queens' THEN 'QN'
        WHEN borough = 'Staten Island' THEN 'SI'
    END);

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