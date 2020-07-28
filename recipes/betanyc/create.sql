CREATE TEMP TABLE tmp (
    geo_housenum text,
    geo_streetname text,
    geo_borough text,
    geo_nta text,
    geo_latitude double precision,
    geo_longitude double precision,
    geo_grc text,
    geo_grc2 text,
    name text,
    category text,
    subcategory text,
    phone text,
    status text,
    pickup text,
    delivery text,
    hours text,
    special_hours text,
    black_owned	 text,
    mwbe boolean,
    source text,
    last_updated timestamp,
    latitude double precision,
    longitude double precision,
    address text
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE cleaned (
    WITH 
    cleaning as (
        SELECT 
            *,
            COALESCE(
                ST_SetSRID(ST_MakePoint(geo_longitude,geo_latitude),4326)::geometry(Point,4326),
                ST_SetSRID(ST_MakePoint(longitude,latitude),4326)::geometry(Point,4326)
            ) as geom
        FROM tmp
    ) 
    SELECT 
        name,
        category,
        subcategory,
        phone,
        address,
        zipcode,
        COALESCE(
            (CASE 
                WHEN geo_borough = 'BRONX' THEN 'BX'
                WHEN geo_borough = 'BROOKLYN' THEN 'BK'
                WHEN geo_borough = 'MANHATTAN' THEN 'MN'
                WHEN geo_borough = 'QUEENS' THEN 'QN'
                WHEN geo_borough = 'STATEN ISLAND' THEN 'SI'
            END), 
            NULL -- replace with spatial join here
        )as borough,
        COALESCE(
            geo_nta,
            NULL -- replace with spatial join here
        ) as nta,
        ntaname,
        status,
        pickup,
        delivery,
        hours,
        special_hours,
        black_owned,
        mwbe,
        source,
        last_updated,
        latitude,
        longitude,
        geom,
        geomsource
    FROM cleaning
);

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT *
INTO :NAME.:"VERSION"
FROM cleaned;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);