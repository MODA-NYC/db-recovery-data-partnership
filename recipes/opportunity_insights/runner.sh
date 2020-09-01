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
        
        NAME=opp_insights_weekly
            
        python3 build_weekly.py |
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
        mkdir -p input
        mkdir -p output

        NAME=opp_insights_daily

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
        Upload $NAME $VERSION
        Upload $NAME latest
    )
    ;;

  *)
    echo -n "please specify weekly or daily"
    ;;
esac
