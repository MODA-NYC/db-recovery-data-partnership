#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)

# StreetEasy NTA Level ETL
(
    cd $BASEDIR
    mkdir -p output
    NAME=$(basename $BASEDIR)
    touch output/urls.txt

    psql $RDP_DATA -f init.sql
    startdate=2019-01-15
    n=0
    VERSION=
    until [ "$VERSION" = "$(get_last_monday $DATE)" ]
    do
        d=$(date -d "$startdate + $n days" +%Y-%m-%d)
        VERSION=$(get_last_monday $d)
        echo "$URL_STREET_EASY$VERSION.csv" >> output/urls.txt

        LOADED=$(psql -q -At $RDP_DATA -c "
            SELECT '$VERSION' IN (
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = '$NAME'
            )")
        
        case $LOADED in
        f)
            echo "Loading $VERSION"
            curl $URL_STREET_EASY$VERSION.csv |
            psql $RDP_DATA -v NAME=street_easy -v VERSION=$VERSION -f create.sql
        ;;
        *)
            echo "$VERSION is already loaded!"
        ;;
        esac
        n=$((n+7))
    done

    (
        cd output

        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT 
                year_week,ntaname,ntacode,borough,borocode,
                s_newlist,s_pendlist,s_list,s_pct_inc,s_pct_dec,
                s_wksonmkt,r_newlist,r_pendlist,r_list,
                r_pct_inc,r_pct_dec,r_pct_furn,r_pct_shor,
                r_pct_con,r_wksonmkt
            FROM $NAME.main
        ) TO stdout DELIMITER ',' CSV HEADER;" > streeteasy_weekly_nta.csv

        # Export to ShapeFile
        SHP_export $RDP_DATA $NAME.latest MULTIPOLYGON streeteasy_weekly_nta.shp

        # Write VERSION info
        echo "$VERSION" > version.txt

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
                SELECT * FROM $NAME.monthly_rental_sales_index_submkt
            ) TO stdout DELIMITER ',' CSV HEADER;" > streeteasy_monthly_rental_sales_index_submkt.csv

            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.monthly_rental_sales_index_boro
            ) TO stdout DELIMITER ',' CSV HEADER;" > streeteasy_monthly_rental_sales_index_boro.csv

        )
    ) 

    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
    Version $NAME '' $VERSION $NAME
) 
