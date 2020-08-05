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
    days_don numeric
);

\COPY tmp FROM PSTDIN DELIMITER '|' CSV HEADER;

-- Create active project table
CREATE SCHEMA IF NOT EXISTS ioby_active_projects;
DROP TABLE IF EXISTS ioby_active_projects.:"VERSION" CASCADE;
SELECT name,
        description,
        zipcode,
        target_rev,
        total_rev,
        date_post,
        date_end
INTO ioby_active_projects.:"VERSION"
FROM tmp 
WHERE status ~* 'underway|open';

DROP VIEW IF EXISTS ioby_active_projects.latest;
CREATE VIEW ioby_active_projects.latest AS (
    SELECT :'VERSION' as v, * 
    FROM ioby_active_projects.:"VERSION"
);

-- Create potential project table
CREATE SCHEMA IF NOT EXISTS ioby_potential_projects;
DROP TABLE IF EXISTS ioby_potential_projects.:"VERSION" CASCADE;
SELECT name,
        description,
        status,
        CASE WHEN project_loc IS NULL OR project_loc='' 
            THEN UPPER(contact_loc) 
            ELSE UPPER(project_loc)
            END as location
INTO ioby_potential_projects.:"VERSION"
FROM tmp 
WHERE status !~* 'underway|open';

DROP VIEW IF EXISTS ioby_potential_projects.latest;
CREATE VIEW ioby_potential_projects.latest AS (
    SELECT :'VERSION' as v, * 
    FROM ioby_potential_projects.:"VERSION"
);

-- Create zipcode aggregation table
DROP VIEW IF EXISTS ioby_active_projects.count_by_zip;
CREATE VIEW ioby_active_projects.count_by_zip AS (
    SELECT b.zipcode, a.sum_donate, a.sum_proj, b.wkb_geometry
    FROM
        (SELECT
            zipcode,
            SUM(total_rev) as sum_donate,
            COUNT(*) as sum_proj
            FROM ioby_active_projects.latest
        GROUP BY zipcode
        ORDER BY zipcode) a 
    RIGHT JOIN doitt_zipcodeboundaries b
    ON a.zipcode::text = b.zipcode::text)
;