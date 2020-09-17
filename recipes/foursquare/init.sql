DO $$
DECLARE
    _main boolean;
    _view boolean;
    _view_grouped boolean;
    _view_weekly_zipcode boolean;
    _view_daily_zipcode boolean;
    
BEGIN
    SELECT 'foursquare_datacube.main' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _main;    
    SELECT 'foursquare_datacube.latest' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view;
    SELECT 'foursquare_datacube.grouped_latest' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_grouped;
    SELECT 'foursquare_datacube.daily_zipcode'  IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_daily_zipcode;
    SELECT 'foursquare_datacube.weekly_zipcode' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_weekly_zipcode;

    IF NOT _main THEN
        CREATE SCHEMA IF NOT EXISTS foursquare_datacube;
        CREATE TABLE foursquare_datacube.main (
            date text,
            country text,
            state text,
            county text,
            zip text,
            categoryid text,
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
        RAISE NOTICE 'Creating foursquare_datacube.main';
    ELSE RAISE NOTICE 'foursquare_datacube.main is created';
    END IF;

    /* Create NYC views */
    IF NOT _view THEN
        CREATE VIEW foursquare_datacube.latest AS (
            SELECT * FROM foursquare_datacube.main 
            WHERE zip in (SELECT DISTINCT zipcode::text FROM doitt_zipcodeboundaries) 
            AND categoryid != 'Group'
        );
        RAISE NOTICE 'Creating foursquare_datacube.latest';
    ELSE RAISE NOTICE 'foursquare_datacube.latest is created';
    END IF;

    IF NOT _view_grouped THEN
        CREATE VIEW foursquare_datacube.grouped_latest AS (
            SELECT * FROM foursquare_datacube.main 
            WHERE zip IN (SELECT DISTINCT zipcode::text FROM doitt_zipcodeboundaries) 
            AND categoryid = 'Group'
        );
        RAISE NOTICE 'Creating foursquare_datacube.grouped_latest';
    ELSE RAISE NOTICE 'foursquare_datacube.grouped_latest is created';
    END IF;

    IF NOT _view_daily_zipcode THEN
        CREATE VIEW foursquare_datacube.daily_zipcode AS (
            SELECT
                date,
                zip as zipcode,
                categoryname as category,
                avg(CASE WHEN demo='All' THEN visits END) AS visits_avg_all,
                avg(CASE WHEN demo='Below65' THEN visits END)AS visits_avg_u65,
                avg(CASE WHEN demo='Above65' THEN visits END) AS visits_avg_o65
            FROM foursquare_datacube.main
            WHERE categoryid = 'Group' and hour = 'All'
            AND zip IN (SELECT DISTINCT zipcode::text FROM doitt_zipcodeboundaries)
            GROUP BY date, zip, category
        );
        RAISE NOTICE 'Creating foursquare_datacube.grouped_daily_zipcode';
    ELSE RAISE NOTICE 'foursquare_datacube.grouped_daily_zipcode is created';
    END IF;

    IF NOT _view_weekly_zipcode THEN
        CREATE VIEW foursquare_datacube.weekly_zipcode AS (
            SELECT
                to_char(date::date, 'IYYY-IW') as year_week,
                zip as zipcode,
                categoryname as category,
                avg(CASE WHEN demo='All' THEN visits END) AS visits_avg_all,
                avg(CASE WHEN demo='Below65' THEN visits END)AS visits_avg_u65,
                avg(CASE WHEN demo='Above65' THEN visits END) AS visits_avg_o65
            FROM foursquare_datacube.main
            WHERE categoryid = 'Group' and hour = 'All'
            AND zip IN (SELECT DISTINCT zipcode::text FROM doitt_zipcodeboundaries)
            GROUP BY to_char(date::date, 'IYYY-IW'), zip, category
        );
        RAISE NOTICE 'Creating foursquare_datacube.grouped_weekly_zipcode';
    ELSE RAISE NOTICE 'foursquare_datacube.grouped_weekly_zipcode is created';
    END IF;
END $$;