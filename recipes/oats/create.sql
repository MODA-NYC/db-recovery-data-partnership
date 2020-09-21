CREATE TEMP TABLE tmp (
    date date,
    zipcode text,
    found_oats text,
    tech_goal text,
    main_issue text,
    computer text,
    internet text,
    email_wkly text,
    email_moly text,
    social_act text,
    shop_bank text,
    devices text,
    non_eng text,
    job_search text,
    volunteer text,
    interests text,
    age text,
    gender text,
    hhld_size text,
    highest_ed text,
    race text,
    disability text,
    hhld_inc text,
    net_worth text,
    region text
);

\COPY tmp FROM PSTDIN DELIMITER '|' CSV HEADER;

-- Create record-level table
CREATE SCHEMA IF NOT EXISTS oats;
DROP TABLE IF EXISTS oats.:"VERSION" CASCADE;
SELECT date,
        (CASE
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'New York' THEN 'MN'
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'Bronx' THEN 'BX'
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'Kings' THEN 'BK'
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'Queens' THEN 'QN'
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'Richmond' THEN 'SI'
        END) as borough,
        (CASE
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'New York' THEN 1
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'Bronx' THEN 2
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'Kings' THEN 3
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'Queens' THEN 4
            WHEN a.zipcode ~ '^[0-9\-]+$' AND b.county = 'Richmond' THEN 5
        END) as borocode,
        -- NULL out invalid zip codes and convert to 5-digit
        (CASE 
            WHEN a.zipcode ~ '^[0-9\-]+$' 
            AND (LENGTH(a.zipcode) = 5 OR LENGTH(a.zipcode) = 10 OR a.zipcode = '83')
                THEN LEFT(a.zipcode, 5)
            ELSE NULL
        END) as zipcode,
        (CASE
            WHEN b.county IS NOT NULL THEN 'NYC'
            WHEN a.region = 'Region'
                AND a.zipcode ~ '^[0-9\-]+$' 
                AND (LENGTH(a.zipcode) = 5 OR LENGTH(a.zipcode) = 10 OR a.zipcode = '83')
                THEN 'Region'
            WHEN a.zipcode ~ '^[0-9\-]+$' 
                AND (LENGTH(a.zipcode) = 5 OR LENGTH(a.zipcode) = 10 OR a.zipcode = '83')
                THEN 'Nation'
            ELSE  NULL
        END) as location,
        a.found_oats,
        a.tech_goal,
        a.main_issue,
        -- Clean category typos from input data
        CASE
            WHEN a.computer = 'Note sure' THEN 'Not Sure'
            ELSE a.computer
        END as computer,
        a.internet,
        a.email_wkly,
        a.email_moly,
        a.social_act,
        a.shop_bank,
        a.devices,
        a.non_eng,
        a.job_search,
        a.volunteer,
        a.interests,
        a.age,
        a.gender,
        a.hhld_size,
        REPLACE(a.highest_ed,'â€™','''') as highest_ed,
        a.race,
        a.disability,
        a.hhld_inc,
        a.net_worth
INTO oats.:"VERSION"
FROM tmp a 
LEFT JOIN doitt_zipcodeboundaries b 
ON LEFT(a.zipcode, 5) = b.zipcode::text;

DROP VIEW IF EXISTS oats.latest CASCADE;
CREATE VIEW oats.latest AS (
    SELECT :'VERSION' as v, * 
    FROM oats.:"VERSION"
);
