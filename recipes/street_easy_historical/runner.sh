#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
startdate=2019-01-15
n=0
VERSION=
until [ "$VERSION" = "$(get_last_monday $DATE)" ]
do  
    d=$(date -d "$startdate + $n days" +%Y-%m-%d)
    VERSION=$(get_last_monday $d)
    echo "Version: $VERSION"

    # StreetEasy NTA Level ETL
    (
        cd $BASEDIR
        mkdir -p output
        NAME=street_easy
        
        echo "$URL_STREET_EASY$VERSION.csv"

        python3 build.py $VERSION | 
        psql $RDP_DATA -v NAME=street_easy -v VERSION=$VERSION -f create.sql

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

        Upload $NAME $VERSION
        Upload $NAME latest
        rm -rf output
    ) 
    n=$((n+7))
done