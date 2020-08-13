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

    (
        cd output
        
        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM upsolve.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > upsolve_responses.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM upsolve.count_by_zip
        ) TO stdout DELIMITER ',' CSV HEADER;" > upsolve_count_by_zip.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM upsolve.sum_by_zip
        ) TO stdout DELIMITER ',' CSV HEADER;" > upsolve_sum_by_zip.csv

        # Export to ShapeFile
        SHP_export $RDP_DATA upsolve.count_by_zip MULTIPOLYGON upsolve_count_by_zip
        SHP_export $RDP_DATA upsolve.sum_by_zip MULTIPOLYGON upsolve_sum_by_zip

        # Write VERSION info
        echo "$VERSION" > version.txt
    )
    Upload $NAME $VERSION
    Upload $NAME latest
)
