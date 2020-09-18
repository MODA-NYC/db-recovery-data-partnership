#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE

(
    cd $BASEDIR
    mkdir -p output
    mkdir -p input

    mc cp $GSHEET_CRED creds.json

    python3 build.py |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql
    
    rm creds.json
    rm -rf input
    (
        cd output
        
        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM upsolve.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > upsolve_responses.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM upsolve.count_by_zip
        ) TO stdout DELIMITER ',' CSV HEADER;" > upsolve_weekly_count_by_zip.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM upsolve.sum_by_zip
        ) TO stdout DELIMITER ',' CSV HEADER;" > upsolve_sum_by_zip.csv

        # Write VERSION info
        echo "$VERSION" > version.txt
    )

    # Export to Shapefile
    SHP_export $RDP_DATA upsolve.sum_by_zip MULTIPOLYGON upsolve_sum_by_zip

    # Upload $NAME latest
    rm -rf output
)
