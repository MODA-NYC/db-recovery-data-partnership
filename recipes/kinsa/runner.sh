#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE
AWS_ACCESS_KEY_ID=$KINSA_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$KINSA_SECRET_ACCESS_KEY

(
    cd $BASEDIR
    mkdir -p output
    mkdir -p input

    aws s3 cp s3://kinsa-share/kinsa_gamma_signal.csv input/kinsa_gamma_signal.csv
    cat input/kinsa_gamma_signal.csv |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql
    rm -rf input

    (
        cd output
           
        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM $NAME.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > kinsa_illness.csv

        # Write VERSION info
        echo "$VERSION" > version.txt
    )
    
    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
)
