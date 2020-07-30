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

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
WITH unpivot AS(
    SELECT 
        date,
        state,
        (CASE 
            WHEN borough = 'Bronx County' THEN 'BX'
            WHEN borough = 'Brooklyn' THEN 'BK'
            WHEN borough = 'New York' THEN 'MN'
            WHEN borough = 'Queens' THEN 'QN'
            WHEN borough = 'Staten Island' THEN 'SI'
        END) as borough,
        categoryid,
        categoryname,
        (CASE
            WHEN demo = 'All' THEN visits
            ELSE 0
        END) AS visits_all,
        (CASE
            WHEN demo = 'Below65' THEN visits 
            ELSE 0 
        END) AS visits_u65,
        (CASE
            WHEN demo = 'Above65' THEN visits 
            ELSE 0 
        END) AS visits_o65,
        (CASE
            WHEN demo = 'All' THEN avgduration 
            ELSE 0 
        END) AS avgdur_all,
        (CASE
            WHEN demo = 'Below65' THEN avgduration 
            ELSE 0 
        END) AS avgdur_u65,
        (CASE
            WHEN demo = 'Above65' THEN avgduration 
            ELSE 0 
        END) AS avgdur_o65,
        (CASE
            WHEN demo = 'All' THEN p50duration 
            ELSE 0 
        END) AS p50dur_all,
        (CASE
            WHEN demo = 'Below65' THEN p50duration 
            ELSE 0 
        END) AS p50dur_u65,
        (CASE
            WHEN demo = 'Above65' THEN p50duration 
            ELSE 0 
        END) AS p50dur_o65
    FROM tmp
)

SELECT date,
        state,
        borough,
        categoryid,
        categoryname,
        SUM(visits_all) as visits_all,
        SUM(visits_u65) as visits_u65,
        SUM(visits_o65) as visits_o65,
        SUM(avgdur_all) as avgdur_all,
        SUM(avgdur_u65) as avgdur_u65,
        SUM(avgdur_o65) as avgdur_o65,
        SUM(p50dur_all) as p50dur_all,
        SUM(p50dur_u65) as p50dur_u65,
        SUM(p50dur_o65) as p50dur_o65
INTO :NAME.:"VERSION"
FROM unpivot
GROUP BY date, state, borough, categoryid, categoryname;

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