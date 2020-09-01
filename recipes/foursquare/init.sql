DO $$
DECLARE
    _main boolean;
    _view boolean;
    _view_grouped boolean;
BEGIN
    SELECT 'foursquare_datacube.main' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _main;    
    SELECT 'foursquare_datacube.grouped_latest' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view;
    SELECT 'foursquare_datacube.latest' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view_grouped;

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

    /* Create NYC views */
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
            WHERE zip in (SELECT DISTINCT zipcode::text FROM doitt_zipcodeboundaries) 
            AND categoryid = 'Group'
        );
        RAISE NOTICE 'Creating foursquare_datacube.grouped_latest';
    ELSE RAISE NOTICE 'foursquare_datacube.grouped_latest is created';
    END IF;
END $$;
