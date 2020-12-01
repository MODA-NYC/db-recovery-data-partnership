#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)

# StreetEasy NTA Level ETL
(
    cd $BASEDIR
    mkdir -p output
    NAME=$(basename $BASEDIR)
    VERSION=$DATE

    # StreetEasy NTA Metrics
    (
        python3 build_nta.py | psql $RDP_DATA -v VERSION=$VERSION -f create_nta.sql

        (
            cd output

            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT 
                    year_week,ntaname,ntacode,borough,borocode,
                    s_newlist,s_pendlist,s_list,s_pct_inc,s_pct_dec,
                    s_wksonmkt,r_newlist,r_pendlist,r_list,
                    r_pct_inc,r_pct_dec,r_pct_furn,r_pct_shot,
                    r_pct_con,r_wksonmkt
                FROM streeteasy_weekly_nta.latest
            ) TO stdout DELIMITER ',' CSV HEADER;" > streeteasy_weekly_nta.csv

            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT 
                    year_week,ntaname,ntacode,borough,borocode,numrooms,
                    s_newlist,s_pendlist,s_list,s_pct_inc,s_pct_dec,
                    s_wksonmkt,r_newlist,r_pendlist,r_list,
                    r_pct_inc,r_pct_dec,r_pct_furn,r_pct_shot,
                    r_pct_con,r_wksonmkt
                FROM streeteasy_weekly_nta_by_rooms.latest
            ) TO stdout DELIMITER ',' CSV HEADER;" > streeteasy_weekly_nta_by_rooms.csv

            # Export to ShapeFile
            SHP_export $RDP_DATA $NAME.latest MULTIPOLYGON streeteasy_weekly_nta.shp

            # Write VERSION info
            echo "$VERSION" > version.txt
        )

    )

    # StreetEasy Rental/Sales Indecies
    (
        NAME=street_easy_rental_sales_index
        
        python3 build_rental_sales_index.py |
        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_rental_sales_index.sql

        (
            cd output

            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > streeteasy_monthly_rental_sales_index.csv

        )
    ) 

    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
    Version $NAME '' $VERSION $NAME
) 
