#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE

(
    cd $BASEDIR
    mkdir -p output

    docker run --rm\
            -v $(pwd)/../:/recipes\
            -e NAME=$NAME\
            -e STREET_EASY_AWS=$STREET_EASY_AWS\
            -w /recipes/$NAME\
            nycplanning/cook:latest python3 build.py | 
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
) 