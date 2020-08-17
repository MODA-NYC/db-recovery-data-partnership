CREATE TEMP TABLE tmp (
    date date,
    zip text,
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
    location text
);

\COPY tmp FROM PSTDIN DELIMITER '|' CSV HEADER;

-- Create record-level table
CREATE SCHEMA IF NOT EXISTS oats;
DROP TABLE IF EXISTS oats.:"VERSION" CASCADE;
SELECT date,
        -- NULL out invalid zip codes and convert to 5-digit
        CASE 
            WHEN zip ~ '^[0-9]+$' AND LENGTH(zip) = 5
                THEN zip
            WHEN zip ~ '^[0-9\-]+$' AND LENGTH(zip) = 10
                THEN LEFT(zip, 5)
            ELSE NULL
        END as zip,
        location,
        found_oats,
        tech_goal,
        main_issue,
        -- Clean category typos from input data
        CASE
            WHEN computer = 'Note sure' THEN 'Not Sure'
            ELSE computer
        END as computer,
        internet,
        email_wkly,
        email_moly,
        social_act,
        shop_bank,
        devices,
        non_eng,
        job_search,
        volunteer,
        interests,
        age,
        gender,
        hhld_size,
        highest_ed,
        race,
        disability,
        hhld_inc,
        net_worth
INTO oats.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS oats.latest CASCADE;
CREATE VIEW oats.latest AS (
    SELECT :'VERSION' as v, * 
    FROM oats.:"VERSION"
);
