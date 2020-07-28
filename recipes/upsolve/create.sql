CREATE TMP TABLE tmp(
        interview_date timestamp,
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
        zip int,
        borough varchar(2)
);

COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

-- Create response table and pivot gender
DROP TABLE IF EXISTS upsolve_responses.:"VERSION" CASCADE;
SELECT 
    *,
    CASE 
        WHEN gender_male IS TRUE THEN 'male'
        WHEN gender_female IS TRUE THEN 'female'
        WHEN gender_tmale IS TRUE THEN 'transmale'
        WHEN gender_tfemale IS TRUE THEN 'transfemale'
        WHEN gender_queer IS TRUE THEN 'queer'
        WHEN gender_other IS TRUE THEN 'other'
        ELSE NULL
    END as gender
INTO upsolve_responses.:"VERSION"
FROM tmp;

-- Remove bool gender columns
ALTER TABLE upsolve_responses.:"VERSION"
DROP COLUMN gender_male,
DROP COLUMN gender_female,
DROP COLUMN gender_tmale,
DROP COLUMN gender_tfemale,
DROP COLUMN gender_queer,
DROP COLUMN gender_other;

-- Create zip-week aggregation
CREATE VIEW upsolve.count_by_zip(
    SELECT 
        a.zipcode, a.year_week, a.count, b.wkb_geometry
    FROM(
        SELECT 
            zipcode, 
            to_char(interview_date, 'IYYY-IW') as year_week,
            count(*) as count
        FROM upsolve.latest
        GROUP BY zipcode, to_char(interview_date, 'IYYY-IW')
        ORDER BY zipcode, to_char(interview_date, 'IYYY-IW')  
    ) a 
    LEFT JOIN doitt_zipcodeboundaries b
    ON a.zipcode::text = b.zipcode::text
);