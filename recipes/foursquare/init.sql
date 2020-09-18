DO $$
DECLARE
    _main boolean;
    _view boolean;
    _view_weekly_zipcode boolean;
    _view_daily_zipcode boolean;
    
BEGIN
    SELECT 'foursquare_zipcode.main' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _main;    
    SELECT 'foursquare_zipcode.latest' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view;
    SELECT 'foursquare_zipcode.daily_zipcode'  IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_daily_zipcode;
    SELECT 'foursquare_zipcode.weekly_zipcode' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_weekly_zipcode;

    IF NOT _main THEN
        CREATE SCHEMA IF NOT EXISTS foursquare_zipcode;
        CREATE TABLE foursquare_zipcode.main (
            date date,
            country text,
            state text,
            county text,
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

    /* Create NYC views */
    IF NOT _view THEN
        CREATE VIEW foursquare_zipcode.latest AS (
            SELECT * FROM foursquare_zipcode.main 
            WHERE zip in (SELECT DISTINCT zipcode::text FROM doitt_zipcodeboundaries) 
        );
        RAISE NOTICE 'Creating foursquare_zipcode.latest';
    ELSE RAISE NOTICE 'foursquare_zipcode.latest is created';
    END IF;

    IF NOT _view_daily_zipcode THEN
        CREATE VIEW foursquare_zipcode.daily_zipcode AS (
            SELECT
                date,
                zip as zipcode,
                categoryname as category,
                avg(CASE WHEN demo='All' THEN visits END) AS visits_avg_all,
                avg(CASE WHEN demo='Below65' THEN visits END)AS visits_avg_u65,
                avg(CASE WHEN demo='Above65' THEN visits END) AS visits_avg_o65
            FROM foursquare_zipcode.main
            WHERE hour = 'All'
            AND zip IN (SELECT DISTINCT zipcode::text FROM doitt_zipcodeboundaries)
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
                categoryname as category,
                avg(CASE WHEN demo='All' THEN visits END) AS visits_avg_all,
                avg(CASE WHEN demo='Below65' THEN visits END)AS visits_avg_u65,
                avg(CASE WHEN demo='Above65' THEN visits END) AS visits_avg_o65
            FROM foursquare_zipcode.main
            WHERE hour = 'All'
            AND zip IN (SELECT DISTINCT zipcode::text FROM doitt_zipcodeboundaries)
            GROUP BY to_char(date::date, 'IYYY-IW'), zip, category
        );
        RAISE NOTICE 'Creating foursquare_zipcode.weekly_zipcode';
    ELSE RAISE NOTICE 'foursquare_zipcode.weekly_zipcode is created';
    END IF;
END $$;