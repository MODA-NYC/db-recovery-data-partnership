#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
VERSION=$DATE
TYPE=$1 #cityhall/weekly/daily
sectors=('automotive' 'dining' 'healthcare' 'lifestyle' 'malls' 'retail' 'telco' 'transportation')

case $TYPE in

  cityhall)
    (
        cd $BASEDIR
        NAME=cuebiq_cityhall
        mkdir -p output
        mkdir -p input

        (
            cd input
            touch raw_$NAME.csv
            for i in $(mc --json ls cuebiq/cuebiq-dataset-nv/1/ce-an-994/)
            do
                key=$(echo $i | jq '.key' -r)
                mc cp cuebiq/cuebiq-dataset-nv/1/ce-an-994/$key tmp.csv
                tail -n +2 tmp.csv >> raw_$NAME.csv
                rm tmp.csv
            done
        )

        cat input/raw_$NAME.csv |
        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql

        (
            cd output
            
            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv

            # Write VERSION info
            echo "$VERSION" > version.txt
        )
        Upload $NAME $VERSION
        Upload $NAME latest
    )
    ;;

  weekly)
    (
        cd $BASEDIR
        NAME=cuebiq_weekly

        (
            cd input
            touch raw_$NAME.csv
            for sector in "${sectors[@]}"
            do
                mc cp cuebiq/cuebiq-dataset-nv/offline-intelligence/index=cvi/sector=$sector/country=US/cvi-$sector.csv000.gz cvi-$sector.csv000.gz
                gunzip cvi-$sector.csv000.gz
                tail -n +2 cvi-$sector.csv000 >> raw_$NAME.csv
                rm cvi-$sector.csv000
            done
        )

        cat input/raw_$NAME.csv |
        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_weekly.sql

        (
            cd output
            
            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv
        )
        Upload $NAME $VERSION
        Upload $NAME latest
    )
    ;;

  daily)
    (
        cd $BASEDIR
        NAME=cuebiq_daily

        (
            cd input
            for sector in "${sectors[@]}"
            do
                mc cp cuebiq/cuebiq-dataset-nv/offline-intelligence/index=cvi/sector=$sector/country=US/daily-cvi-$sector.csv000.gz \
                    daily-cvi-$sector.csv000.gz &
            done
            wait
        )

        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_daily.sql

        (
            cd output
            
            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv
            zip $NAME.zip $NAME.csv
            rm $NAME.csv
        )
        Upload $NAME $VERSION
        Upload $NAME latest
    )
    ;;

  *)
    echo -n "please specify cityhall, weekly or daily"
    ;;
esac
