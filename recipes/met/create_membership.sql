CREATE TEMP TABLE tmp (
    date date,
    count int,
    transaction_type text
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS met_membership;
DROP TABLE IF EXISTS met_membership.:"VERSION" CASCADE;
SELECT
    date,
    to_char(date, 'IYYY-IW') as year_week,
    building,
    count,
    transaction_type as type
INTO met_membership.:"VERSION" 
FROM tmp a;

DROP VIEW IF EXISTS met_membership.latest;
CREATE VIEW met_membership.latest AS (
    SELECT :'VERSION' as v, * 
    FROM met_membership.:"VERSION"
);

CREATE SCHEMA IF NOT EXISTS met_membership_weekly;
DROP TABLE IF EXISTS met_membership_weekly.:"VERSION" CASCADE;
SELECT
    to_char(date, 'IYYY-IW') as year_week,
    SUM(count) as count,
    transaction_type as type
INTO met_membership_weekly.:"VERSION" 
FROM tmp a
GROUP BY year_week, transaction_type;

DROP VIEW IF EXISTS met_attendence_weekly.latest;
CREATE VIEW met_attendence_weekly.latest AS (
    SELECT :'VERSION' as v, * 
    FROM met_membership_weekly.:"VERSION"
);