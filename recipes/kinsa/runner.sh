#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE

(
    cd $BASEDIR
    mkdir -p output
    mkdir -p input

    mc cp kinsa/kinsa-share/kinsa_gamma_signal.csv input/kinsa_gamma_signal.csv
    cat input/kinsa_gamma_signal.csv |
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
