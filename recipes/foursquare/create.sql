CREATE TEMP TABLE tmp (
    date timestamp,
    state text,
    borough text,
    categoryid text,
    categoryname text,
    demo text,
    visits numeric,
    avgDuration numeric,
    p50Duration numeric
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

CREATE SCHEMA IF NOT EXISTS foursquare_grouped;
DROP TABLE IF EXISTS foursquare_grouped.:"VERSION";
SELECT *
INTO foursquare_grouped.:"VERSION"
FROM :NAME.:"VERSION"
WHERE categoryid='Grouped';

DELETE
FROM :NAME.:"VERSION"
WHERE categoryid='Grouped';

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);

DROP VIEW IF EXISTS foursquare_grouped.latest;
CREATE VIEW foursquare_grouped.latest AS (
    SELECT :'VERSION' as v, * 
    FROM foursquare_grouped:"VERSION"
);