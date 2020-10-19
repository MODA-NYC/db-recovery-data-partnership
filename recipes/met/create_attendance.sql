CREATE TEMP TABLE tmp (
    date date,
    building text,
    count int,
    type text,
    method text,
    state text,
    country text
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS met_attendence;
DROP TABLE IF EXISTS met_attendence.:"VERSION" CASCADE;
SELECT
    date,
    to_char(date, 'day') as day_of_week,
    to_char(date, 'IYYY-IW') as year_week,
    building,
    count as visits,
    type,
    method,
    state,
    country
INTO met_attendence.:"VERSION" 
FROM tmp a;

DROP VIEW IF EXISTS met_attendence.latest;
CREATE VIEW met_attendence.latest AS (
    SELECT :'VERSION' as v, * 
    FROM met_attendence.:"VERSION"
);

CREATE SCHEMA IF NOT EXISTS met_attendence_weekly;
DROP TABLE IF EXISTS met_attendence_weekly.:"VERSION" CASCADE;
SELECT
    to_char(date, 'IYYY-IW') as year_week,
    building,
    SUM(count) as visits,
    type,
    method,
    state,
    country
INTO met_attendence_weekly.:"VERSION" 
FROM tmp a
GROUP BY year_week, building, type, method, state, country;

DROP VIEW IF EXISTS met_attendence_weekly.latest;
CREATE VIEW met_attendence_weekly.latest AS (
    SELECT :'VERSION' as v, * 
    FROM met_attendence_weekly.:"VERSION"
);