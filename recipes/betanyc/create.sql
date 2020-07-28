CREATE TEMP TABLE tmp (
    geo_housenum text,
    geo_streetname text,
    geo_borough text,
    geo_nta text,
    geo_latitude double precision,
    geo_longitude double precision,
    geo_grc text,
    geo_grc2 text,
    zipcode text,
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
    mwbe text,
    source text,
    last_updated timestamp,
    latitude double precision,
    longitude double precision,
    address text
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE TEMP TABLE cleaned as (
    WITH 
    cleaning as (
        SELECT 
            *,
            COALESCE(
                ST_SetSRID(ST_MakePoint(geo_longitude,geo_latitude),4326)::geometry(Point,4326),
                ST_SetSRID(ST_MakePoint(longitude,latitude),4326)::geometry(Point,4326)
            ) as geom,
            (CASE 
                WHEN geo_longitude is not null 
                THEN 'geosupport' 
                ELSE 'original' 
            END) as geomsource
        FROM tmp
    ) 
    SELECT 
        name,
        (CASE 
            WHEN category ~* 'Groceries|Grocery' then 'Grocery'
            WHEN category ~* 'Shops|Retail|shipping' then 'Shop or Service' 
            WHEN category ~* 'cafe|bakeries|bakery|dessert|coffee' then 'Restaurant or Cafe'  
            WHEN category ~* 'Restaurant|bar' then 'Restaurant or Bar'  
            WHEN category ~* 'Pharmacies|Pharmacy|health|doctor|wellness' then 'Health and Wellness'
            WHEN category ~* 'Laundromat' then 'Laundromat'
            WHEN category ~* 'Community|pantry|free food|Soup Kitchen' then 'Community Services'
            WHEN category ~* 'Wine|Liquor' then 'Liquor Store'
            WHEN category ~* 'hardware' then 'Hardware Store'
            WHEN category ~* 'bike|bicyle' then 'Bike Shop'
            ELSE 'Other'
        END) as category,
        subcategory,
        phone,
        address,
        COALESCE(
            zipcode, 
            (SELECT b.zipcode::text 
            FROM doitt_zipcodeboundaries b 
            WHERE st_within(geom, b.wkb_geometry))
        ) as zipcode,
        COALESCE(
            (CASE 
                WHEN geo_borough = 'BRONX' THEN 'BX'
                WHEN geo_borough = 'BROOKLYN' THEN 'BK'
                WHEN geo_borough = 'MANHATTAN' THEN 'MN'
                WHEN geo_borough = 'QUEENS' THEN 'QN'
                WHEN geo_borough = 'STATEN ISLAND' THEN 'SI'
            END), 
            (SELECT 
                (CASE 
                    WHEN b.county = 'Bronx' THEN 'BX'
                    WHEN b.county = 'Kings' THEN 'BK'
                    WHEN b.county = 'New York' THEN 'MN'
                    WHEN b.county = 'Queens' THEN 'QN'
                    WHEN b.county = 'Richmond' THEN 'SI'
                END) from doitt_zipcodeboundaries b where st_within(geom, b.wkb_geometry))
        )as borough,
        COALESCE(
            geo_nta,
            NULL -- replace with spatial join here
        ) as nta,
        null as nta_name,
        (CASE 
            WHEN status ~* 'open' then 'open'
            WHEN status ~* 'closed' then 'closed'
        END) as status,
        (CASE 
            WHEN pickup ~* 'yes' then 'yes'
            WHEN pickup ~* 'no' then 'no'
        END) as pickup,
        (CASE 
            WHEN delivery ~* 'yes' then 'yes'
            WHEN delivery ~* 'no' then 'no'
        END) as delivery,
        hours,
        special_hours,
        (CASE 
            WHEN black_owned ~* 'true' then 'yes'
        END) as black_owned,
        (CASE 
            WHEN mwbe ~* 'true' then 'yes'
        END) as mwbe,
        source,
        last_updated,
        ST_Y(geom) as latitude,
        ST_X(geom) as longitude,
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