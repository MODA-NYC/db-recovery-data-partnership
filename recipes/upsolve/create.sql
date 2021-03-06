CREATE TEMP TABLE tmp(
        date date,
        birth_year smallint,
        race_white boolean,
        race_black boolean,
        race_hispanic boolean,
        race_asian boolean,
        race_nativeamer boolean,
        gender_male boolean,
        gender_female boolean,
        gender_tmale boolean,
        gender_tfemale boolean,
        gender_queer boolean,
        gender_other boolean,
        r_lostjob boolean,
        r_paycut boolean,
        r_familyincome boolean,
        r_injured boolean,
        r_medbills boolean,
        r_spending boolean,
        r_genbills boolean,
        r_garnishedwages boolean,
        r_divorce boolean,
        r_housing boolean,
        r_car boolean,
        r_other boolean,
        r_otherdesc varchar,
        r_top varchar,
        r_covid19 boolean,
        o_gencutback boolean,
        o_bills boolean,
        o_sold boolean,
        o_borrowed boolean,
        o_nomedcare boolean,
        o_soughtjob boolean,
        o_counseling boolean,
        o_negotiated boolean,
        o_lawyer boolean,
        alt_option text,
        state varchar(2),
        zipcode int,
        borough varchar(2)
);

\COPY tmp FROM PSTDIN DELIMITER '|' CSV HEADER;

-- Create response table, pivot gender, order columns
CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT
    md5(CAST((tmp.*)AS text)) as id,
    date,
    birth_year,
    race_white,
    race_black,
    race_hispanic,
    race_asian,
    race_nativeamer,
    CASE 
        WHEN gender_male IS TRUE THEN 'male'
        WHEN gender_female IS TRUE THEN 'female'
        WHEN gender_tmale IS TRUE THEN 'transmale'
        WHEN gender_tfemale IS TRUE THEN 'transfemale'
        WHEN gender_queer IS TRUE THEN 'queer'
        WHEN gender_other IS TRUE THEN 'other'
        ELSE NULL
    END as gender,
    r_lostjob,
    r_paycut,
    r_familyincome,
    r_injured,
    r_medbills,
    r_spending,
    r_genbills,
    r_garnishedwages,
    r_divorce,
    r_housing,
    r_car,
    r_other,
    r_otherdesc,
    r_top,
    r_covid19,
    o_gencutback,
    o_bills,
    o_sold,
    o_borrowed,
    o_nomedcare,
    o_soughtjob,
    o_counseling,
    o_negotiated,
    o_lawyer,
    alt_option,
    zipcode,
    borough,
    (CASE
        WHEN borough = 'MN' THEN 1
        WHEN borough = 'BX' THEN 2
        WHEN borough = 'BK' THEN 3
        WHEN borough = 'QN' THEN 4
        WHEN borough = 'SI' THEN 5
    END) as borocode
INTO :NAME.:"VERSION"
FROM tmp;

DROP VIEW IF EXISTS :NAME.latest CASCADE;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
); 

-- Create zip-week aggregation
DROP VIEW IF EXISTS :NAME.weekly_count_by_zip;
CREATE VIEW :NAME.weekly_count_by_zip AS
    SELECT 
        b.zipcode, 
        a.year_week, 
        a.total, 
        a.sum_covid, 
        a.per_covid,
        a.borough,
        (CASE
            WHEN a.borough = 'MN' THEN 1
            WHEN a.borough = 'BX' THEN 2
            WHEN a.borough = 'BK' THEN 3
            WHEN a.borough = 'QN' THEN 4
            WHEN a.borough = 'SI' THEN 5
        END) as borocode
    FROM(
        SELECT 
            zipcode,
            borough, 
            to_char(date, 'IYYY-IW') as year_week,
            count(*) as total,
            count(CASE WHEN r_covid19 THEN 1 END) as sum_covid,
            ROUND(count(CASE WHEN r_covid19 THEN 1 END)::numeric*100/count(*), 2) as per_covid
        FROM :NAME.:"VERSION"
        GROUP BY zipcode, borough, to_char(date, 'IYYY-IW')
        ORDER BY zipcode, borough, to_char(date, 'IYYY-IW')  
    ) a 
    RIGHT JOIN doitt_zipcodeboundaries b
    ON a.zipcode::text = b.zipcode::text
;

-- Create zip aggregation of total counts to date
DROP VIEW IF EXISTS :NAME.sum_by_zip;
CREATE VIEW :NAME.sum_by_zip AS
    SELECT 
        b.zipcode, 
        a.total, 
        a.sum_covid, 
        a.per_covid,
        a.borough,
        (CASE
            WHEN a.borough = 'MN' THEN 1
            WHEN a.borough = 'BX' THEN 2
            WHEN a.borough = 'BK' THEN 3
            WHEN a.borough = 'QN' THEN 4
            WHEN a.borough = 'SI' THEN 5
        END) as borocode,
        b.wkb_geometry
    FROM(
        SELECT 
            zipcode, 
            borough,
            count(*) as total,
            count(CASE WHEN r_covid19 THEN 1 END) as sum_covid,
            ROUND(count(CASE WHEN r_covid19 THEN 1 END)::numeric*100/count(*), 2) as per_covid
        FROM :NAME.:"VERSION"
        GROUP BY zipcode, borough
        ORDER BY zipcode, borough
    ) a 
    RIGHT JOIN doitt_zipcodeboundaries b
    ON a.zipcode::text = b.zipcode::text
;