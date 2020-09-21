BEGIN;

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
    access_other text,
    activities text,
    activities_other text,
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
    END) as zipcode,
    (CASE
        WHEN borough = 'Queens' THEN 'QN'
        WHEN borough = 'Staten Island' THEN 'SI'
        WHEN borough = 'Manhattan' THEN 'MN'
        WHEN borough = 'Bronx' THEN 'BX'
        WHEN borough = 'Brooklyn' THEN 'BK'
    END) as borough,
    (CASE
        WHEN borough = 'Queens' THEN 4
        WHEN borough = 'Staten Island' THEN 5
        WHEN borough = 'Manhattan' THEN 1
        WHEN borough = 'Bronx' THEN 2
        WHEN borough = 'Brooklyn' THEN 3
    END) as borocode,
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
    (CASE WHEN access ~* 'Public park' THEN 'Yes' END) as access_park,
    (CASE WHEN access ~* 'Public plaza' THEN 'Yes' END) as access_plaza,
    (CASE WHEN access ~* 'Sidewalk' THEN 'Yes' END) as access_sidewalk,
    (CASE WHEN access ~* 'Beach' THEN 'Yes' END) as access_beach,
    (CASE WHEN access ~* 'Community garden' THEN 'Yes' END) as access_garden,
    (CASE WHEN access ~* 'Bike path' THEN 'Yes' END) as access_bikepath,
    (CASE WHEN access ~* 'Private yard or garden (belonging to your household)' THEN 'Yes' END) as access_yard,
    (CASE WHEN access ~* 'NYCHA outdoor space' THEN 'Yes' END) as access_nycha,
    (CASE WHEN access ~* 'Private patio, porch, terrace, or balcony (belonging to your household)' THEN 'Yes' END) as access_balcony,
    (CASE WHEN access ~* 'Shared yard, courtyard, garden or rooftop' THEN 'Yes' END) as access_shared,
    (CASE WHEN access ~* 'Street open for social distancing' THEN 'Yes' END) as access_street,
    (CASE WHEN access ~* 'Natural area' THEN 'Yes' END) as natural,
    (CASE WHEN access ~* 'Beach' THEN 'Yes' END) as access_other,
    access_other,
    (CASE WHEN activities ~* 'Visiting parks or open space' THEN 'Yes' END) as activities_park,
    (CASE WHEN activities ~* 'Using NYCHA open spaces' THEN 'Yes' END) as activities_nycha,
    (CASE WHEN activities ~* 'Going on walks' THEN 'Yes' END) as activities_walk,
    (CASE WHEN activities ~* 'Outdoor recreation' THEN 'Yes' END) as activities_rec,
    (CASE WHEN activities ~* 'Outdoor exercise' THEN 'Yes' END) as activities_exercise,
    (CASE WHEN activities ~* 'Walking a dog' THEN 'Yes' END) as activities_dog,
    (CASE WHEN activities ~* 'Gardening' THEN 'Yes' END) as activities_garden,
    (CASE WHEN activities ~* 'Birdwatching' THEN 'Yes' END) as activities_birds,
    (CASE WHEN activities ~* 'Caring for indoor plants' THEN 'Yes' END) as activities_plants,
    (CASE WHEN activities ~* 'Observing natrue through the window' THEN 'Yes' END) as activities_window,
    (CASE WHEN activities ~* 'Fishing' THEN 'Yes' END) as activities_fish,
    activities_other,
    REPLACE(diff_park,' during Covid-19 crisis','') as diff_park,
    REPLACE(diff_nycha,' during Covid-19 crisis','') as diff_nycha,
    REPLACE(diff_walk,' during Covid-19 crisis','') as diff_walk,
    REPLACE(diff_rec,' during Covid-19 crisis','') as diff_rec,
    REPLACE(diff_exrcz,' during Covid-19 crisis','') as diff_exercise,
    REPLACE(diff_dog,' during Covid-19 crisis','') as diff_dog,
    REPLACE(diff_grdn,' during Covid-19 crisis','') as diff_garden,
    REPLACE(diff_birds,' during Covid-19 crisis','') as diff_birds,
    REPLACE(diff_plants,' during Covid-19 crisis','') as diff_plants,
    REPLACE(diff_wndw,' during Covid-19 crisis','') as diff_window,
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
    (CASE WHEN social_in_pk ~* 'Family members' THEN 'Yes' END) as social_family,
    (CASE WHEN social_in_pk ~* 'Friends' THEN 'Yes' END) as social_friend,
    (CASE WHEN social_in_pk ~* 'Neighbors' THEN 'Yes' END) as social_neighbor,
    (CASE WHEN social_in_pk ~* 'Strangers' THEN 'Yes' END) as social_stranger,
    (CASE WHEN social_in_pk ~* 'No one' THEN 'Yes' END) as social_noone,
    (CASE WHEN pk_priority ~* 'Landscaping maintained gardens, flowers, or lawn' THEN 'Yes' END) as priority_landscaping,
    (CASE WHEN pk_priority ~* 'Socializing, spending time with others' THEN 'Yes' END) as priority_socializing,
    (CASE WHEN pk_priority ~* 'Places to sit' THEN 'Yes' END) as priority_seating,
    (CASE WHEN pk_priority ~* 'Places to walk' THEN 'Yes' END) as priority_trails,
    (CASE WHEN pk_priority ~* 'Educational opportunities' THEN 'Yes' END) as priority_education,
    (CASE WHEN pk_priority ~* 'Opportunities to view wildlife' THEN 'Yes' END) as priority_wildlife,
    (CASE WHEN pk_priority ~* 'Place for children to play' THEN 'Yes' END) as priority_play,
    (CASE WHEN pk_priority ~* 'Places to exercise, play sports' THEN 'Yes' END) as priority_exercise,
    (CASE WHEN pk_priority ~* 'Dog-friendly' THEN 'Yes' END) as priority_dog,
    (CASE WHEN pk_priority ~* 'Water feature' THEN 'Yes' END) as priority_water,
    (CASE WHEN pk_priority ~* 'Trees, shade' THEN 'Yes' END) as priority_trees,
    (CASE WHEN pk_priority ~* 'Places to BBQ, cook food' THEN 'Yes' END) as priority_bbq,
    other_pk_priority as priority_other,
    (CASE WHEN pk_benefits ~* 'Landscaping maintained gardens, flowers, or lawn' THEN 'Yes' END) as benefit_landscaping,
    (CASE WHEN pk_benefits ~* 'Socializing, spending time with others' THEN 'Yes' END) as benefit_socializing,
    (CASE WHEN pk_benefits ~* 'Places to sit' THEN 'Yes' END) as benefit_seating,
    (CASE WHEN pk_benefits ~* 'Places to walk' THEN 'Yes' END) as benefit_trails,
    (CASE WHEN pk_benefits ~* 'Educational opportunities' THEN 'Yes' END) as benefit_education,
    (CASE WHEN pk_benefits ~* 'Opportunities to view wildlife' THEN 'Yes' END) as benefit_wildlife,
    (CASE WHEN pk_benefits ~* 'Place for children to play' THEN 'Yes' END) as benefit_play,
    (CASE WHEN pk_benefits ~* 'Places to exercise, play sports' THEN 'Yes' END) as benefit_exercise,
    (CASE WHEN pk_benefits ~* 'Dog-friendly' THEN 'Yes' END) as benefit_dog,
    (CASE WHEN pk_benefits ~* 'Water feature' THEN 'Yes' END) as benefit_water,
    (CASE WHEN pk_benefits ~* 'Trees, shade' THEN 'Yes' END) as benefit_trees,
    (CASE WHEN pk_benefits ~* 'Places to BBQ, cook food' THEN 'Yes' END) as benefit_bbq,
    TRIM(
        REGEXP_REPLACE(
            CONCAT_WS(',', pk_concerns, other_pk_concerns, pk_safety_concerns),
            '\s+', ' ', 'g')) as pk_concerns,
    access_limit,
    unhappy,
    lost_sleep,
    lost_focus,
    enjoyment,
    os_mental_pre,
    os_mental_post,
    os_physical_pre,
    os_physical_post,
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

COMMIT;