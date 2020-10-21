BEGIN;

CREATE TEMP TABLE tmp (
    date date,
    building text,
    count int,
    type text,
    method text,
    state text,
    country text
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV ENCODING 'LATIN1';

CREATE SCHEMA IF NOT EXISTS met_attendance;
DROP TABLE IF EXISTS met_attendance.:"VERSION" CASCADE;
SELECT
    date,
    extract(dow from date) as day_of_week,
    to_char(date, 'IYYY-IW') as year_week,
    building,
    count as visits,
    type,
    method,
    nullif(state, 'Unknown') as state,
    nullif(country, 'Unknown') as country
INTO met_attendance.:"VERSION" 
FROM tmp a
ORDER BY date, state, country;

DROP VIEW IF EXISTS met_attendance.latest;
CREATE VIEW met_attendance.latest AS (
    SELECT :'VERSION' as v, * 
    FROM met_attendance.:"VERSION"
);

CREATE SCHEMA IF NOT EXISTS met_attendance_weekly;
DROP TABLE IF EXISTS met_attendance_weekly.:"VERSION" CASCADE;
SELECT
    to_char(date, 'IYYY-IW') as year_week,
    building,
    SUM(count) as visits,
    type,
    method,
    nullif(state, 'Unknown') as state,
    nullif(country, 'Unknown') as country
INTO met_attendance_weekly.:"VERSION" 
FROM tmp a
GROUP BY year_week, building, type, method, state, country
ORDER BY year_week, state, country;

DROP VIEW IF EXISTS met_attendance_weekly.latest;
CREATE VIEW met_attendance_weekly.latest AS (
    SELECT :'VERSION' as v, * 
    FROM met_attendance_weekly.:"VERSION"
);

COMMIT;