CREATE TEMP TABLE tmp (
    date date,
    zip text,
    borough text,
    neighborhood text,
    nyc_res text,
    distancing text,
    time_dist text,
    left_home text,
    feel_safe text,
    can_dist text,
    access text,
    activities text,
    other_activities text,
    diff_park text,
    diff_nycha text,
    diff_walk text,
    diff_rec text,
    diff_exrcz text,
    diff_dog text,
    diff_grdn text,
    diff_birds text,
    diff_plants text,
    diff_wndw text,
    diff_fish text,
    diff_other text,
    to_park text,
    other_to_park text,
    time_to_pk text,
    wkly_visits text,
    time_in_pk text,
    last_visit text,
    mood_in_pk text,
    stress_in_pk text,
    social_in_pk text,
    pk_priority text,
    other_pk_priority text,
    pk_benefits text,
    pk_concerns text,
    other_pk_concerns text,
    pk_safety_concerns text,
    access_limit text,
    unhappy text,
    lost_sleep text,
    lost_focus text,
    enjoyment text,
    os_mntlhlth_pre text,
    os_mntlhlth_post text,
    pk_mntlhlth_pre text,
    pk_mntlhlth_post text,
    park_desc text,
    place_living text,
    other_place_living text,
    home_type text,
    other_home_type text,
    public_housing text,
    hhld_u18 text,
    hhld_18_to_59 text,
    hhld_o59 text,
    severe_risk text,
    diff_inc text,
    age text,
    gender text,
    other_gender text,
    hispanic text,
    race text,
    other_race text,
    highest_ed  text,
    hhld_inc text,
    notes text
);

\COPY tmp FROM PSTDIN DELIMITER '|' CSV HEADER;

-- Create record-level table
CREATE SCHEMA IF NOT EXISTS usl;
DROP TABLE IF EXISTS usl.:"VERSION" CASCADE;
SELECT
    date,
    (CASE
        WHEN zip IS NOT NULL AND LEFT(zip, 5) ~ '^[0-9]*$'
        THEN LEFT(zip, 5)
        ELSE NULL
    END) as zip,
    borough,
    neighborhood,
    nyc_res,
    distancing,
    time_dist,
    left_home,
    (CASE
        WHEN feel_safe IS NOT NULL
        THEN LEFT(feel_safe, 1)::int
        ELSE NULL
    END) as feel_safe, 
    can_dist,
    access,
    CONCAT_WS(',', activities, other_activities) as activities,
    REPLACE(diff_park,' during Covid-19 crisis','') as diff_park,
    REPLACE(diff_nycha,' during Covid-19 crisis','') as diff_nycha,
    REPLACE(diff_walk,' during Covid-19 crisis','') as diff_walk,
    REPLACE(diff_rec,' during Covid-19 crisis','') as diff_rec,
    REPLACE(diff_exrcz,' during Covid-19 crisis','') as diff_exrcz,
    REPLACE(diff_dog,' during Covid-19 crisis','') as diff_dog,
    REPLACE(diff_grdn,' during Covid-19 crisis','') as diff_grdn,
    REPLACE(diff_birds,' during Covid-19 crisis','') as diff_birds,
    REPLACE(diff_plants,' during Covid-19 crisis','') as diff_plants,
    REPLACE(diff_wndw,' during Covid-19 crisis','') as diff_wndw,
    REPLACE(diff_fish,' during Covid-19 crisis','') as diff_fish,
    REPLACE(diff_other,' during Covid-19 crisis','') as diff_other,
    (CASE
        WHEN to_park LIKE 'Other:%' OR to_park IS NULL
        THEN other_to_park
        ELSE to_park
    END) as to_park,
    time_to_pk,
    wkly_visits,
    time_in_pk,
    last_visit,
    mood_in_pk,
    REPLACE(stress_in_pk, ' stress', '') as stress_in_pk,
    social_in_pk,
    TRIM(
        REGEXP_REPLACE(
            CONCAT_WS(',', pk_priority, other_pk_priority), 
            '\s+', ' ', 'g')) as pk_priority,
    TRIM(
        REGEXP_REPLACE(pk_benefits, '\s+', ' ', 'g')) as pk_benefits,
    TRIM(
        REGEXP_REPLACE(
            CONCAT_WS(',', pk_concerns, other_pk_concerns, pk_safety_concerns),
            '\s+', ' ', 'g')) as pk_concerns,
    access_limit,
    unhappy,
    lost_sleep,
    lost_focus,
    enjoyment,
    os_mntlhlth_pre,
    os_mntlhlth_post,
    pk_mntlhlth_pre,
    pk_mntlhlth_post,
    park_desc,
    (CASE
        WHEN place_living ~ 'Other:' OR place_living IS NULL
        THEN other_place_living
        ELSE place_living
    END) as place_living,
    (CASE
        WHEN home_type ~ 'Other:' OR home_type IS NULL
        THEN other_home_type
        ELSE home_type
    END) as home_type,
    public_housing,
    hhld_u18,
    hhld_18_to_59,
    hhld_o59,
    severe_risk,
    diff_inc,
    age,
    COALESCE(gender, other_gender) as gender,
    hispanic,
    (CASE
        WHEN race ~ 'Other:' OR race IS NULL
        THEN other_race
        ELSE race
    END) as race,
    highest_ed,
    hhld_inc,
    notes
INTO usl.:"VERSION"
FROM tmp
WHERE nyc_res <> 'No' AND
    (zip IS NOT NULL OR
    borough IS NOT NULL OR
    neighborhood IS NOT NULL OR
    distancing IS NOT NULL OR
    time_dist IS NOT NULL OR
    left_home IS NOT NULL OR
    feel_safe IS NOT NULL OR
    can_dist IS NOT NULL OR
    access IS NOT NULL OR
    activities IS NOT NULL OR
    other_activities IS NOT NULL OR
    diff_park IS NOT NULL OR
    diff_nycha IS NOT NULL OR
    diff_walk IS NOT NULL OR
    diff_rec IS NOT NULL OR
    diff_exrcz IS NOT NULL OR
    diff_dog IS NOT NULL OR
    diff_grdn IS NOT NULL OR
    diff_birds IS NOT NULL OR
    diff_plants IS NOT NULL OR
    diff_wndw IS NOT NULL OR
    diff_fish IS NOT NULL OR
    diff_other IS NOT NULL OR
    to_park IS NOT NULL OR
    other_to_park IS NOT NULL OR
    time_to_pk IS NOT NULL OR
    wkly_visits IS NOT NULL OR
    time_in_pk IS NOT NULL OR
    last_visit IS NOT NULL OR
    mood_in_pk IS NOT NULL OR
    stress_in_pk IS NOT NULL OR
    social_in_pk IS NOT NULL OR
    pk_priority IS NOT NULL OR
    other_pk_priority IS NOT NULL OR
    pk_benefits IS NOT NULL OR
    pk_concerns IS NOT NULL OR
    other_pk_concerns IS NOT NULL OR
    pk_safety_concerns IS NOT NULL OR
    access_limit IS NOT NULL OR
    unhappy IS NOT NULL OR
    lost_sleep IS NOT NULL OR
    lost_focus IS NOT NULL OR
    enjoyment IS NOT NULL OR
    os_mntlhlth_pre IS NOT NULL OR
    os_mntlhlth_post IS NOT NULL OR
    pk_mntlhlth_pre IS NOT NULL OR
    pk_mntlhlth_post IS NOT NULL OR
    park_desc IS NOT NULL OR
    place_living IS NOT NULL OR
    other_place_living IS NOT NULL OR
    home_type IS NOT NULL OR
    other_home_type IS NOT NULL OR
    public_housing IS NOT NULL OR
    hhld_u18 IS NOT NULL OR
    hhld_18_to_59 IS NOT NULL OR
    hhld_o59 IS NOT NULL OR
    severe_risk IS NOT NULL OR
    diff_inc IS NOT NULL OR
    age IS NOT NULL OR
    gender IS NOT NULL OR
    other_gender IS NOT NULL OR
    hispanic IS NOT NULL OR
    race IS NOT NULL OR
    other_race IS NOT NULL OR
    highest_ed  IS NOT NULL OR
    hhld_inc IS NOT NULL OR
    notes IS NOT NULL);

DROP VIEW IF EXISTS usl.latest CASCADE;
CREATE VIEW usl.latest AS (
    SELECT :'VERSION' as v, * 
    FROM usl.:"VERSION"
);