CREATE TEMP TABLE tmp (
    name text,
    description text,
    status text,
    contact_loc text,
    project_loc text,
    zipcode text,
    target_rev numeric,
    total_rev numeric,
    date_post date,
    date_end date,
    days_don numeric,
    donation numeric,
    don_date date,
    project text,
    don_city text,
    don_type text,
    order_id text
);

\COPY tmp FROM PSTDIN DELIMITER '|' CSV HEADER;

-- Create active project table
CREATE SCHEMA IF NOT EXISTS ioby_active_projects;
DROP TABLE IF EXISTS ioby_active_projects.:"VERSION" CASCADE;
SELECT DISTINCT name,
        description,
        zipcode,
        target_rev,
        total_rev,
        date_post,
        date_end,
        days_don
INTO ioby_active_projects.:"VERSION"
FROM tmp 
WHERE status ~* 'underway|open';

DROP VIEW IF EXISTS ioby_active_projects.latest CASCADE;
CREATE VIEW ioby_active_projects.latest AS (
    SELECT :'VERSION' as v, * 
    FROM ioby_active_projects.:"VERSION"
);

-- Create potential project table
CREATE SCHEMA IF NOT EXISTS ioby_potential_projects;
DROP TABLE IF EXISTS ioby_potential_projects.:"VERSION" CASCADE;
SELECT DISTINCT name,
        description,
        status,
        CASE WHEN project_loc IS NULL OR project_loc='' 
            THEN UPPER(contact_loc) 
            ELSE UPPER(project_loc)
            END as city
INTO ioby_potential_projects.:"VERSION"
FROM tmp 
WHERE status !~* 'underway|open';

DROP VIEW IF EXISTS ioby_potential_projects.latest CASCADE;
CREATE VIEW ioby_potential_projects.latest AS (
    SELECT :'VERSION' as v, * 
    FROM ioby_potential_projects.:"VERSION"
);

-- Create week-zipcode donation aggregation table
CREATE SCHEMA IF NOT EXISTS ioby_donations;
DROP TABLE IF EXISTS ioby_donations.:"VERSION" CASCADE;
WITH 
distinct_donations AS(
    SELECT DISTINCT
        zipcode,
        don_date,
        donation,
        project,
        don_type,
        order_id
    FROM tmp
    )
SELECT 
    (CASE
        WHEN b.county = 'New York' THEN 'MN'
        WHEN b.county = 'Bronx' THEN 'BX'
        WHEN b.county = 'Kings' THEN 'BK'
        WHEN b.county = 'Queens' THEN 'QN'
        WHEN b.county = 'Richmond' THEN 'SI'
    END) as borough,
    (CASE
        WHEN b.county = 'New York' THEN 1
        WHEN b.county = 'Bronx' THEN 2
        WHEN b.county = 'Kings' THEN 3
        WHEN b.county = 'Queens' THEN 4
        WHEN b.county = 'Richmond' THEN 5
    END) as borocode,
    b.zipcode, 
    a.year_week, 
    a.sum_donate, 
    a.sum_proj
INTO ioby_donations.:"VERSION"
FROM
    (SELECT
        zipcode,
        to_char(don_date, 'IYYY-IW') as year_week,
        SUM(donation) as sum_donate,
        COUNT(DISTINCT project) as sum_proj
        FROM distinct_donations
    GROUP BY zipcode, year_week) a 
RIGHT JOIN doitt_zipcodeboundaries b
ON a.zipcode::text = b.zipcode::text
ORDER BY zipcode, year_week
;

DROP VIEW IF EXISTS ioby_donations.latest;
CREATE VIEW ioby_donations.latest AS (
    SELECT :'VERSION' as v, * 
    FROM ioby_donations.:"VERSION"
);

-- Create zipcode aggregation table
DROP VIEW IF EXISTS ioby_active_projects.count_by_zip;
CREATE VIEW ioby_active_projects.count_by_zip AS (
    SELECT 
    (CASE
        WHEN b.county = 'New York' THEN 'MN'
        WHEN b.county = 'Bronx' THEN 'BX'
        WHEN b.county = 'Kings' THEN 'BK'
        WHEN b.county = 'Queens' THEN 'QN'
        WHEN b.county = 'Richmond' THEN 'SI'
    END) as borough,
    (CASE
        WHEN b.county = 'New York' THEN 1
        WHEN b.county = 'Bronx' THEN 2
        WHEN b.county = 'Kings' THEN 3
        WHEN b.county = 'Queens' THEN 4
        WHEN b.county = 'Richmond' THEN 5
    END) as borocode,
    b.zipcode, 
    a.sum_donate, 
    a.sum_proj
    FROM
        (SELECT DISTINCT
            zipcode,
            SUM(total_rev) as sum_donate,
            COUNT(*) as sum_proj
            FROM ioby_active_projects.latest
        GROUP BY zipcode
        ORDER BY zipcode) a 
    RIGHT JOIN doitt_zipcodeboundaries b
    ON a.zipcode::text = b.zipcode::text)
;