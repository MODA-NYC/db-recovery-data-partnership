#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
VERSION=$(get_last_monday $DATE)
echo "Version: $VERSION"

# StreetEasy NTA Level ETL
(
    cd $BASEDIR
    mkdir -p output
    NAME=$(basename $BASEDIR)
    
    echo "$URL_STREET_EASY$VERSION.csv"

    python3 build.py $VERSION | 
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql

    (
        cd output

        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM $NAME.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > street_easy_nta.csv

        # Export to ShapeFile
        SHP_export $RDP_DATA $NAME.latest MULTIPOLYGON street_easy_nta

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
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv

        )
    ) 

    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
) 
