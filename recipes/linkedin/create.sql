CREATE TEMP TABLE tmp (
    month_begin_date date,
    hiring_rate_sa numeric,
    mom_change numeric,
    yoy_change numeric
); 

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;

CREATE SCHEMA IF NOT EXISTS :NAME;
DROP TABLE IF EXISTS :NAME.:"VERSION" CASCADE;
SELECT 
    to_char(month_begin_date,'YYYY-MM') as year_month,
    hiring_rate_sa,
    mom_change,
    yoy_change
INTO :NAME.:"VERSION" FROM tmp;

DROP VIEW IF EXISTS :NAME.latest;
CREATE VIEW :NAME.latest AS (
    SELECT :'VERSION' as v, * 
    FROM :NAME.:"VERSION"
);