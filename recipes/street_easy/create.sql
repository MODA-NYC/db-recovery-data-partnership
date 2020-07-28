CREATE TEMP TABLE tmp(
    nta_name text,
    nta_code varchar(4),
    s_newlist int,
    s_pendlist int,
    s_list int,
    s_pct_inc double precision,
    s_pct_dec double precision,
    s_wksonmkt double precision,
    r_newlist int,
    r_pendlist int,
    r_list int,
    r_pct_inc double precision,
    r_pct_dec double precision,
    r_pct_furn double precision,
    r_pct_shor double precision,
    r_pct_con double precision,
    r_wksonmkt double precision,
    week_start timestamp,
    week_end timestamp
)


\COPY tmp FROM PSTDIN DELIMITER '|' CSV HEADER;

-- Join with NTA geometry and round
CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT 
    a.nta_name,
    a.nta_code,
    a.s_newlist,
    a.s_pendlist,
    a.s_list,
    ROUND(a.s_pct_inc*100, 2) as s_pct_inc,
    ROUND(a.s_pct_dec*100, 2) as s_pct_dec,
    ROUND(a.s_wksonmkt, 1) as s_wksonmkt,
    a.r_newlist,
    a.r_pendlist,
    a.r_list,
    ROUND(a.r_pct_inc*100, 2) as r_pct_inc,
    ROUND(a.r_pct_dec*100, 2) as r_pct_dec,
    ROUND(a.r_pct_furn*100, 2) as r_pct_furn,
    ROUND(a.r_pct_shor*100, 2) as r_pct_shor,
    ROUND(a.r_pct_con*100, 2) as r_pct_con,
    ROUND(a.r_wksonmkt, 1) as r_wksonmkt,
    week_start timestamp,
    week_end timestamp,
    b.geom
INTO :NAME.:"VERSION"
FROM tmp a
JOIN dcp_ntaboundaries b
ON a.nta_code = b.ntacode
;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
); 