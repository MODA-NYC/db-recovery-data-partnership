CREATE TEMP TABLE tmp (
    fipscounty text,
    year text,
    month text,
    day_endofweek text,
    engagement numeric,
    badges numeric,
    imputed_from_cz boolean,
    initial_claims numeric,
    total_claims numeric,
    initial_claims_rate numeric,
    total_claims_rate numeric
);

\COPY tmp FROM PSTDIN DELIMITER ',' CSV HEADER;