DO $$
DECLARE
    _schema boolean;
    _main boolean;
    _view boolean;
BEGIN
    SELECT 'street_easy' IN (SELECT table_schema FROM information_schema.tables) INTO _schema;    
    SELECT 'street_easy.main' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _main;    
    SELECT 'street_easy.latest' IN (SELECT table_schema||'.'||table_name FROM information_schema.tables) INTO _view;

    IF NOT _schema THEN 
        CREATE SCHEMA IF NOT EXISTS street_easy;
    END IF;
    
    IF NOT _main THEN
        CREATE TABLE street_easy.main (
            year_week text,
            ntaname text,
            ntacode character varying(4),
            s_newlist integer,
            s_pendlist integer,
            s_list integer,
            s_pct_inc numeric,
            s_pct_dec numeric,
            s_wksonmkt numeric,
            r_newlist integer,
            r_pendlist integer,
            r_list integer,
            r_pct_inc numeric,
            r_pct_dec numeric,
            r_pct_furn numeric,
            r_pct_shor numeric,
            r_pct_con numeric,
            r_wksonmkt numeric,
            geom geometry(MultiPolygon,4326)
        );
        RAISE NOTICE 'Creating street_easy.main';
    ELSE RAISE NOTICE 'street_easy.main is created';
    END IF;

    /* Create NYC views */
    IF NOT _view THEN
        CREATE VIEW street_easy.latest AS (
            SELECT * from street_easy.main
            WHERE year_week=(select max(year_week) from street_easy.main)
        );
        RAISE NOTICE 'Creating street_easy.latest';
    ELSE RAISE NOTICE 'street_easy.latest is created';
    END IF;
END $$;