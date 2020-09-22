DO $$
DECLARE
    _main boolean;
    _latest boolean;
    _view_weekly_zipcode boolean;
    _view_daily_zipcode boolean;
    _view_daily_zipcode_timeofday boolean;
BEGIN
    SELECT 'foursquare_zipcode.main' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _main;    
    SELECT 'foursquare_zipcode.latest' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _latest;    
    SELECT 'foursquare_zipcode.daily_zipcode'  IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_daily_zipcode;
    SELECT 'foursquare_zipcode.weekly_zipcode' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_weekly_zipcode;
    SELECT 'foursquare_zipcode.daily_zipcode_timeofday' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_daily_zipcode_timeofday;

    IF NOT _main THEN
        CREATE SCHEMA IF NOT EXISTS foursquare_zipcode;
        CREATE TABLE foursquare_zipcode.main (
            date date,
            zip text,
            categoryname text,
            hour text,
            demo text,
            visits numeric,
            avgduration numeric,
            medianduration text,
            pctto10mins numeric,
            pctto20mins numeric,
            pctto30mins numeric,
            pctto60mins numeric,
            pctto2hours numeric,
            pctto4hours numeric,
            pctto8hours numeric,
            pctover8hours numeric
        );
        RAISE NOTICE 'Creating foursquare_zipcode.main';
    ELSE RAISE NOTICE 'foursquare_zipcode.main is created';
    END IF;

    IF NOT _latest THEN
        CREATE view foursquare_zipcode.latest AS (
            SELECT 
                date,
                to_char(date::date, 'IYYY-IW') as year_week,
                date_part('dow', date) as day_of_week,
                zip as zipcode,
                (SELECT boro from city_zip_boro a where zip=a.zipcode) as borough,
                (SELECT 
                    (CASE
                        WHEN a.boro = 'QN' THEN 4
                        WHEN a.boro = 'SI' THEN 5
                        WHEN a.boro = 'MN' THEN 1
                        WHEN a.boro = 'BX' THEN 2
                        WHEN a.boro = 'BK' THEN 3
                    END)
                from city_zip_boro a where zip=a.zipcode) as borocode,
                categoryname as category,
                hour,
                demo,
                visits,
                avgduration,
                medianduration,
                pctto10mins,
                pctto20mins,
                pctto30mins,
                pctto60mins,
                pctto2hours,
                pctto4hours,
                pctto8hours,
                pctover8hours
            FROM foursquare_zipcode.main 
        );
        RAISE NOTICE 'Creating foursquare_zipcode.latest';
    ELSE RAISE NOTICE 'foursquare_zipcode.latest is created';
    END IF;

    IF NOT _view_daily_zipcode THEN
        CREATE VIEW foursquare_zipcode.daily_zipcode AS (

            SELECT
                date,
                zip as zipcode,
                (SELECT boro from city_zip_boro a where zip=a.zipcode) as borough,
                (SELECT 
                    (CASE
                        WHEN a.boro = 'QN' THEN 4
                        WHEN a.boro = 'SI' THEN 5
                        WHEN a.boro = 'MN' THEN 1
                        WHEN a.boro = 'BX' THEN 2
                        WHEN a.boro = 'BK' THEN 3
                    END)
                from city_zip_boro a where zip=a.zipcode) as borocode,
                categoryname as category,
                avg(CASE WHEN demo='All' THEN visits END) AS visits_avg_all,
                avg(CASE WHEN demo='Below65' THEN visits END)AS visits_avg_u65,
                avg(CASE WHEN demo='Above65' THEN visits END) AS visits_avg_o65
            FROM foursquare_zipcode.main
            WHERE hour = 'All'
            GROUP BY date, zip, category
        );
        RAISE NOTICE 'Creating foursquare_zipcode.daily_zipcode';
    ELSE RAISE NOTICE 'foursquare_zipcode.daily_zipcode is created';
    END IF;

    IF NOT _view_weekly_zipcode THEN
        CREATE VIEW foursquare_zipcode.weekly_zipcode AS (
            SELECT
                to_char(date::date, 'IYYY-IW') as year_week,
                zip as zipcode,
                (SELECT boro from city_zip_boro a where zip=a.zipcode) as borough,
                (SELECT 
                    (CASE
                        WHEN a.boro = 'QN' THEN 4
                        WHEN a.boro = 'SI' THEN 5
                        WHEN a.boro = 'MN' THEN 1
                        WHEN a.boro = 'BX' THEN 2
                        WHEN a.boro = 'BK' THEN 3
                    END)
                from city_zip_boro a where zip=a.zipcode) as borocode,
                categoryname as category,
                avg(CASE WHEN demo='All' THEN visits END) AS visits_avg_all,
                avg(CASE WHEN demo='Below65' THEN visits END)AS visits_avg_u65,
                avg(CASE WHEN demo='Above65' THEN visits END) AS visits_avg_o65
            FROM foursquare_zipcode.main
            WHERE hour = 'All'
            GROUP BY to_char(date::date, 'IYYY-IW'), zip, category
        );
        RAISE NOTICE 'Creating foursquare_zipcode.weekly_zipcode';
    ELSE RAISE NOTICE 'foursquare_zipcode.weekly_zipcode is created';
    END IF;

    IF NOT _view_daily_zipcode_timeofday THEN
        CREATE VIEW foursquare_zipcode.daily_zipcode_timeofday AS (
            SELECT 
                date,
                year_week, 
                zipcode,
                borough, 
                borocode,
                category,
                SUM(CASE WHEN demo='Below65' AND hour='All' THEN visits END)AS visits_u65,
                SUM(CASE WHEN demo='Above65' AND hour='All' THEN visits END) AS visits_o65,
                SUM(CASE WHEN demo='All' AND hour='Morning' THEN visits END) AS visits_morning,
                SUM(CASE WHEN demo='All' AND hour='Late Morning' THEN visits END) AS visits_latemorning,
                SUM(CASE WHEN demo='All' AND hour='Early Afternoon' THEN visits END) AS visits_earlyafternoon,
                SUM(CASE WHEN demo='All' AND hour='Late Afternoon' THEN visits END) AS visits_lateafternoon,
                SUM(CASE WHEN demo='All' AND hour='Evening' THEN visits END) AS visits_evening,
                SUM(CASE WHEN demo='All' AND hour='Late Evening' THEN visits END) AS visits_lateevening,
                SUM(CASE WHEN demo='All' AND hour='Night' THEN visits END) AS visits_night,
                SUM(CASE WHEN demo='All' AND hour='Late Night' THEN visits END) AS visits_latenight
            FROM (
                SELECT
                    date,
                    to_char(date::date, 'IYYY-IW') as year_week,
                    zip as zipcode, 
                    (SELECT boro from city_zip_boro a where zip=a.zipcode) as borough,
                    (SELECT 
                        (CASE
                            WHEN a.boro = 'QN' THEN 4
                            WHEN a.boro = 'SI' THEN 5
                            WHEN a.boro = 'MN' THEN 1
                            WHEN a.boro = 'BX' THEN 2
                            WHEN a.boro = 'BK' THEN 3
                        END)
                    from city_zip_boro a where zip=a.zipcode) as borocode,
                    categoryname as category,
                    hour, demo,
                    avg(visits) as visits
                FROM foursquare_zipcode.main
                GROUP BY date, to_char(date::date, 'IYYY-IW'), hour, demo, zip, borough, borocode, category
            ) a
            GROUP BY date, year_week, zipcode, borough, borocode, category
        );
        RAISE NOTICE 'Creating foursquare_zipcode.daily_zipcode_timeofday';
    ELSE RAISE NOTICE 'foursquare_zipcode.daily_zipcode_timeofday is created';
    END IF;
END $$;
