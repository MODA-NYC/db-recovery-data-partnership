#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
AWS_ACCESS_KEY_ID=$CUEBIQ_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$CUEBIQ_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=us-east-1

function cuebiq_travelers {
    (
        cd $BASEDIR
        NAME=cuebiq_travelers

        (
            cd input
            touch raw_$NAME.csv
            aws s3 sync s3://cuebiq-dataset-nv/d4g/travelers/country=US/state=NY/ .
            for i in $(ls vdate=*/travelers-*.csv000.gz)
            do
                FILE=$(echo "$i" | cut -f 1 -d '.')
                yes n | gunzip $i
                tail -n +2 $FILE.csv000 >> raw_$NAME.csv
                rm $FILE.csv000
            done
        )

        cat input/raw_$NAME.csv |
        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_travelers.sql
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
    )
}