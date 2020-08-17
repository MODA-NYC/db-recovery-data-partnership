#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE

(
    cd $BASEDIR
    echo "Pulling data from dropbox"

    mkdir -p input && (
        cd input
        curl -L -o raw.xlsx $URL_OATS
    )

    python3 build.py |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql

    (
        cd output

        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM $NAME.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > oats_records.csv

        # Write VERSION info
        echo "$VERSION" > version.txt
        
    )

    Upload $NAME $VERSION
    Upload $NAME latest
)
