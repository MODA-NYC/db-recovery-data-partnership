BEGIN;

CREATE TEMP TABLE tmp(
    ntaname text,
    ntacode varchar(4),
    s_newlist decimal,
    s_pct_inc decimal,
    s_pct_dec decimal,
    s_pendlist decimal,
    s_list decimal,
    s_wksonmkt decimal,
    r_newlist decimal,
    r_pct_inc decimal,
    r_pct_dec decimal,
    r_pendlist decimal,
    r_list decimal,
    r_pct_furn decimal,
    r_pct_shot decimal,
    r_pct_con decimal,
    r_wksonmkt decimal,
    numrooms text,
    week_start date
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

-- Join with NTA geometry and round
CREATE SCHEMA IF NOT EXISTS streeteasy_weekly_nta_by_rooms;
DROP TABLE IF EXISTS streeteasy_weekly_nta_by_rooms.:"VERSION" CASCADE;
SELECT 
    to_char(a.week_start, 'IYYY-IW') as year_week,
    a.ntaname,
    a.ntacode,
    LEFT(a.ntacode, 2) as borough,
    (CASE
        WHEN LEFT(a.ntacode, 2) = 'QN' THEN 4
        WHEN LEFT(a.ntacode, 2) = 'SI' THEN 5
        WHEN LEFT(a.ntacode, 2) = 'MN' THEN 1
        WHEN LEFT(a.ntacode, 2) = 'BX' THEN 2
        WHEN LEFT(a.ntacode, 2) = 'BK' THEN 3
    END) as borocode,
    a.numrooms,
    a.s_newlist::int,
    a.s_pendlist::int,
    a.s_list::int,
    ROUND(a.s_pct_inc*100, 2) as s_pct_inc,
    ROUND(a.s_pct_dec*100, 2) as s_pct_dec,
    ROUND(a.s_wksonmkt, 1) as s_wksonmkt,
    a.r_newlist::int,
    a.r_pendlist::int,
    a.r_list::int,
    ROUND(a.r_pct_inc*100, 2) as r_pct_inc,
    ROUND(a.r_pct_dec*100, 2) as r_pct_dec,
    ROUND(a.r_pct_furn*100, 2) as r_pct_furn,
    ROUND(a.r_pct_shot*100, 2) as r_pct_shot,
    ROUND(a.r_pct_con*100, 2) as r_pct_con,
    ROUND(a.r_wksonmkt, 1) as r_wksonmkt,
    b.wkb_geometry as geom
INTO streeteasy_weekly_nta_by_rooms.:"VERSION"
FROM tmp a
JOIN dcp_ntaboundaries b
ON a.ntacode = b.ntacode
WHERE numrooms <> 'All'
;

-- Join with NTA geometry and round
CREATE SCHEMA IF NOT EXISTS streeteasy_weekly_nta;
DROP TABLE IF EXISTS streeteasy_weekly_nta.:"VERSION" CASCADE;
SELECT 
    to_char(a.week_start, 'IYYY-IW') as year_week,
    a.ntaname,
    a.ntacode,
    LEFT(a.ntacode, 2) as borough,
    (CASE
        WHEN LEFT(a.ntacode, 2) = 'QN' THEN 4
        WHEN LEFT(a.ntacode, 2) = 'SI' THEN 5
        WHEN LEFT(a.ntacode, 2) = 'MN' THEN 1
        WHEN LEFT(a.ntacode, 2) = 'BX' THEN 2
        WHEN LEFT(a.ntacode, 2) = 'BK' THEN 3
    END) as borocode,
    a.s_newlist::int,
    a.s_pendlist::int,
    a.s_list::int,
    ROUND(a.s_pct_inc*100, 2) as s_pct_inc,
    ROUND(a.s_pct_dec*100, 2) as s_pct_dec,
    ROUND(a.s_wksonmkt, 1) as s_wksonmkt,
    a.r_newlist::int,
    a.r_pendlist::int,
    a.r_list::int,
    ROUND(a.r_pct_inc*100, 2) as r_pct_inc,
    ROUND(a.r_pct_dec*100, 2) as r_pct_dec,
    ROUND(a.r_pct_furn*100, 2) as r_pct_furn,
    ROUND(a.r_pct_shot*100, 2) as r_pct_shot,
    ROUND(a.r_pct_con*100, 2) as r_pct_con,
    ROUND(a.r_wksonmkt, 1) as r_wksonmkt,
    b.wkb_geometry as geom
INTO streeteasy_weekly_nta.:"VERSION"
FROM tmp a
JOIN dcp_ntaboundaries b
ON a.ntacode = b.ntacode
WHERE numrooms = 'All';

DROP VIEW IF EXISTS streeteasy_weekly_nta.latest;
CREATE VIEW streeteasy_weekly_nta.latest AS (
    SELECT :'VERSION' as v, * 
    FROM streeteasy_weekly_nta.:"VERSION"
); 

DROP VIEW IF EXISTS streeteasy_weekly_nta_by_rooms.latest;
CREATE VIEW streeteasy_weekly_nta_by_rooms.latest AS (
    SELECT :'VERSION' as v, * 
    FROM streeteasy_weekly_nta_by_rooms.:"VERSION"
); 

COMMIT;