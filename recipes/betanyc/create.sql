BEGIN;

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
    betanyc_category text,
    betanyc_subcategory text,
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
    ),
    -- Create normalized categories
    cat AS (SELECT DISTINCT 
            (CASE 
                WHEN betanyc_subcategory ~* 'wine|beer|tea|market|food|bakery|bar|restaurant|grocery|cafe' 
                OR betanyc_category ~* 'bakery|bar|grocer|restaurant|liquor|dessert|coffee|pantry|soup kitchen|food' 
                    THEN 'Food and beverage'
                WHEN betanyc_subcategory ~* 'clothing|fashion|shoe|goods|electronics|hardware|books|home|bicycle|supplies|pet|stationar|building|dollar store|appliance|pharma'
                OR betanyc_category ~* 'retail|bike|bicycle|store|pet|pharmacy|art|yarn' 
                    THEN 'Dry retail' 
                WHEN betanyc_subcategory ~* 'bank|finance|government|repair|shipping|fitness|copies|law|flor'
                OR betanyc_category ~*  'laundromat|wellness|health|doctor|community service|shipping' 
                    THEN 'Services'
                ELSE 'Other'
            END) AS category, 
            betanyc_category, 
            betanyc_subcategory
        FROM tmp),
    -- Create normalized subcategories
    subcat AS (
        SELECT
            *, 
            (CASE 
                WHEN category='Food and beverage'
                THEN CASE
                    WHEN betanyc_subcategory ~* 'diner|meal*takaway|meal*delivery|restaurant'
                        OR betanyc_category ~* 'restaurant' 
                    THEN 'Restaurant'
                    WHEN betanyc_subcategory ~* 'bakery|cafe|coffee|cream|tea|cake|bagel|sandwich'
                        OR betanyc_category ~* 'bakery|dessert|coffee' 
                    THEN 'Bakeries cafes and desserts'
                    WHEN betanyc_subcategory ~* 'grocer|market|convenience|spice|butcher'
                        OR betanyc_category ~* 'grocer' 
                    THEN 'Grocery and market'
                    WHEN betanyc_subcategory ~* 'wine|bar|beer|liquor|night*club' 
                        OR betanyc_category ~* 'bar|liquor'
                    THEN 'Alcohol and bars'
                    WHEN betanyc_subcategory ~* 'pantry|soup kitchen|free' 
                    THEN 'Free food'
                    ELSE 'Other food and beverage'
                END
                WHEN category='Dry retail'
                THEN CASE
                    WHEN betanyc_subcategory ~* 'bike|bicycle'
                        OR betanyc_category ~* 'bike|bicycle' 
                    THEN 'Bike'
                    WHEN betanyc_subcategory ~* 'hardware|garden|home|furniature|flor|appliance|dollar'
                        OR betanyc_category ~* 'hardware' 
                    THEN 'Hardware and home goods'			
                    WHEN betanyc_subcategory ~* 'pet'
                        OR betanyc_category ~* 'pet' 
                    THEN 'Pet supplies'
                    WHEN betanyc_subcategory ~* 'pharma|health|drug'
                        OR betanyc_category ~* 'pharma' 
                    THEN 'Health and beauty'	
                    WHEN betanyc_subcategory ~* 'cloth|fashion|shoe|jewel' 
                    THEN 'Apparel'
                    WHEN betanyc_subcategory ~* 'electronic|computer'
                    THEN 'Electronics'
                    WHEN betanyc_subcategory ~* 'book|stationery|gifts|art'
                    THEN 'Books art and gifts'
                    ELSE 'Other retail'
                END
                WHEN category='Services'
                THEN CASE
                    WHEN betanyc_subcategory ~* 'fitness|gym|pilates|yoga|martial arts'
                    THEN 'Fitness'
                    WHEN betanyc_subcategory ~* 'doctor|dentist|health|medic'
                    THEN 'Healthcare'
                    WHEN betanyc_subcategory ~* 'financ|bank|tax|account|insurance|law'
                    THEN 'Finance and legal'
                    WHEN betanyc_subcategory ~* 'hair|beauty|salon'
                    THEN 'Beauty'
                    WHEN betanyc_subcategory ~* 'laundr'
                    THEN 'Laundry'
                    WHEN betanyc_subcategory ~* 'copies|copy|shipping|post|photo'
                    THEN 'Copies and shipping'
                    WHEN betanyc_subcategory ~* 'repair'
                    THEN 'Repair'
                    WHEN betanyc_subcategory ~* 'veter'
                    THEN 'Veterinary'
                    WHEN betanyc_subcategory ~* 'flor'
                    THEN 'Floral'
                    ELSE 'Other service'
                END
            ELSE 'Other'
            END) as subcategory
        FROM cat) 

    SELECT 
        a.name,
        c.category,
        c.subcategory,
        a.betanyc_category,
        a.betanyc_subcategory,
        a.phone,
        COALESCE(a.geo_housenum||' '||a.geo_streetname, UPPER(a.address)) as address,
        COALESCE(
            a.zipcode, 
            (SELECT b.zipcode::text 
            FROM doitt_zipcodeboundaries b 
            WHERE st_within(a.geom, b.wkb_geometry))
        ) as zipcode,
        COALESCE(
            (CASE 
                WHEN a.geo_borough = 'BRONX' THEN 'BX'
                WHEN a.geo_borough = 'BROOKLYN' THEN 'BK'
                WHEN a.geo_borough = 'MANHATTAN' THEN 'MN'
                WHEN a.geo_borough = 'QUEENS' THEN 'QN'
                WHEN a.geo_borough = 'STATEN ISLAND' THEN 'SI'
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
            a.geo_nta,
            (SELECT b.ntacode::text 
            FROM dcp_ntaboundaries b 
            WHERE st_within(a.geom, b.wkb_geometry))
        ) as ntacode,
        (SELECT ntaname from dcp_ntaboundaries
        WHERE ntacode = COALESCE(
            a.geo_nta,
            (SELECT b.ntacode::text 
            FROM dcp_ntaboundaries b 
            WHERE st_within(a.geom, b.wkb_geometry))
        )) as ntaname,
        (CASE 
            WHEN a.status ~* 'open' then 'open'
            WHEN a.status ~* 'closed' then 'closed'
        END) as status,
        (CASE 
            WHEN a.pickup ~* 'yes' then 'yes'
            WHEN a.pickup ~* 'no' then 'no'
        END) as pickup,
        (CASE 
            WHEN a.delivery ~* 'yes' then 'yes'
            WHEN a.delivery ~* 'no' then 'no'
        END) as delivery,
        a.hours,
        a.special_hours,
        (CASE 
            WHEN a.black_owned ~* 'true' then 'yes'
        END) as black_owned,
        (CASE 
            WHEN a.mwbe ~* 'true' then 'yes'
        END) as mwbe,
        a.source,
        a.last_updated,
        ST_Y(a.geom) as latitude,
        ST_X(a.geom) as longitude,
        a.geom,
        a.geomsource
    FROM cleaning a 
    JOIN subcat c 
    ON a.betanyc_category = c.betanyc_category
    AND a.betanyc_subcategory = c.betanyc_subcategory
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

COMMIT;