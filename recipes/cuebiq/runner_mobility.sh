#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
PARTNER=$(basename $BASEDIR)
AWS_ACCESS_KEY_ID=$CUEBIQ_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$CUEBIQ_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=us-east-1

function cuebiq_mobility {
    (
        cd $BASEDIR
        NAME=cuebiq_mobility
        (
            cd input
            touch raw_$NAME.csv
            aws s3 sync s3://cuebiq-dataset-nv/1/ce-an-994/ .
            for i in $(ls cityhall*.csv)
            do
                tail -n +2 $i >> raw_$NAME.csv
            done
        )

        cat input/raw_$NAME.csv |
        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_mobility.sql
        rm -rf input
        (
            cd output
            
            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv

            # Write VERSION info
            echo "$VERSION" > version.txt
        )
        Upload cuebiq/$NAME $VERSION
        Upload cuebiq/$NAME latest
        rm -rf output
        Version $PARTNER $NAME $VERSION $NAME
    )
}