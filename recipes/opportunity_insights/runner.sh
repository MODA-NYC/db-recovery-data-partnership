#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
VERSION=$DATE
TYPE=$1 #weekly/daily

case $TYPE in

  weekly)
    (
        cd $BASEDIR
        mkdir -p input
        mkdir -p output
        
        NAME=oppinsights_weekly_uiclaims_elearn
            
        python3 build_weekly.py |
        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_weekly.sql

        (
            cd output
            
            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv
        )
        Upload opportunity_insights/$NAME $VERSION
        Upload opportunity_insights/$NAME latest
        rm -rf output
    )
    ;;

  daily)
    (
        cd $BASEDIR
        mkdir -p input
        mkdir -p output

        NAME=oppinsights_daily_mobility_smallbiz

        python3 build_daily.py |
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
        Upload opportunity_insights/$NAME $VERSION
        Upload opportunity_insights/$NAME latest
        rm -rf output
    )
    ;;

  *)
    echo -n "please specify weekly or daily"
    ;;
esac
