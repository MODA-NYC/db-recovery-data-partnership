#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
VERSION=$DATE

startdate=2019-01-01
enddate=$DATE +%Y-%m-%d
d=
n=0
until [ "$d" = "$enddate" ]
do  
    ((n++))
    d=$(date -d "$startdate + $n days" +%Y-%m-%d)
    DOW=$(date -d "$d" +%a)
    if [ "$DOW" == "Mon" ]; then
        echo "$d"
        
        # StreetEasy NTA Level ETL
        (
            cd $BASEDIR
            mkdir -p output
            NAME=$(basename $BASEDIR)

            python3 build.py $d | 
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
    fi
done