#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE

(
    cd $BASEDIR
    mkdir -p input
    mkdir -p output
    
    python3 build.py |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql

    rm -rf input
    mkdir -p output && 
    (
        cd output

        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM $NAME.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > betanyc_businesses.csv

        SHP_export $RDP_DATA $NAME.latest POINT betanyc_businesses.shp

        # Write VERSION info
        echo "$VERSION" > version.txt
        
    )
    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
)
