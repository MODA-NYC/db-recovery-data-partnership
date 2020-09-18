BEGIN;

CREATE TEMP TABLE tmp (
    date date,
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

/* Kepping Group Level data only*/
DELETE FROM tmp
WHERE categoryid != 'Group';

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
CREATE TABLE :NAME.:"VERSION" AS(
    SELECT 
        date,
        (CASE 
            WHEN borough = 'Bronx County' THEN 'BX'
            WHEN borough = 'Brooklyn' THEN 'BK'
            WHEN borough = 'New York' THEN 'MN'
            WHEN borough = 'Queens' THEN 'QN'
            WHEN borough = 'Staten Island' THEN 'SI'
        END) as borough,
        categoryname,
        SUM(CASE WHEN demo = 'All' THEN visits END) AS visits_all,
        SUM(CASE WHEN demo = 'Below65' THEN visits END) AS visits_u65,
        SUM(CASE WHEN demo = 'Above65' THEN visits END) AS visits_o65,
        SUM(CASE WHEN demo = 'All' THEN avgduration END) AS duration_avg_all,
        SUM(CASE WHEN demo = 'Below65' THEN avgduration END) AS duration_avg_u65,
        SUM(CASE WHEN demo = 'Above65' THEN avgduration END) AS duration_avg_o65
    FROM tmp
    GROUP BY date, borough, categoryname
);

DROP TABLE IF EXISTS :NAME.daily_county CASCADE;
SELECT 
    date,
    borough,
    categoryname,
    SUM(visits_all) AS visits_all,
    SUM(visits_u65) AS visits_u65,
    SUM(visits_o65) AS visits_o65,
    ROUND(SUM(duration_avg_all*visits_all)/SUM(visits_all), 2) as duration_avg_all,
    ROUND(SUM(duration_avg_u65*visits_u65)/SUM(visits_u65), 2) as duration_avg_u65,
    ROUND(SUM(duration_avg_o65*visits_o65)/SUM(visits_o65), 2)as duration_avg_o65
INTO :NAME.daily_county
FROM :NAME.:"VERSION"
GROUP BY date, borough, categoryname;

DROP TABLE IF EXISTS :NAME.weekly_county CASCADE;
SELECT 
    to_char(date::date, 'IYYY-IW') year_week,
    borough, categoryname, 
    AVG(visits_all) AS visits_avg_all,
    AVG(visits_u65) AS visits_avg_u65,
    AVG(visits_o65) AS visits_avg_o65,
    ROUND(SUM(duration_avg_all*visits_all)/SUM(visits_all), 2) as duration_avg_all,
    ROUND(SUM(duration_avg_u65*visits_u65)/SUM(visits_u65), 2) as duration_avg_u65,
    ROUND(SUM(duration_avg_o65*visits_o65)/SUM(visits_o65), 2)as duration_avg_o65
INTO :NAME.weekly_county
FROM :NAME.:"VERSION"
GROUP BY year_week, borough, categoryname;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);

COMMIT;