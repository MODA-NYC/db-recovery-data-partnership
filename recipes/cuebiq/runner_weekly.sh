#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
PARTNER=$(basename $BASEDIR)
AWS_ACCESS_KEY_ID=$CUEBIQ_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$CUEBIQ_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=us-east-1
sectors=('automotive' 'dining' 'healthcare' 'lifestyle' 'malls' 'retail' 'telco' 'transportation')

function cuebiq_weekly {
    (
        cd $BASEDIR
        NAME=cuebiq_weekly
        export VERSION=$(aws s3 ls --recursive s3://cuebiq-dataset-nv/offline-intelligence/index=cvi/sector=malls/country=US/ | tail -n 1 | awk '{print $1}')
        echo $VERSION
        (
            cd input
            touch raw_$NAME.csv
            for sector in "${sectors[@]}"
            do
                max_bg_procs 5
                (
                    KEY=$(aws s3 ls --recursive s3://cuebiq-dataset-nv/offline-intelligence/index=cvi/sector=$sector/country=US/ | sort | awk '{print $4}'| grep 'vdate=*' | grep '/cvi-*' | tail -n 1 )
                    TARGET_FILENAME=cvi-$sector.csv000.gz
                    aws s3 cp s3://cuebiq-dataset-nv/$KEY $TARGET_FILENAME
                    gunzip cvi-$sector.csv000.gz
                    tail -n +2 cvi-$sector.csv000 >> raw_$NAME.csv
                    rm cvi-$sector.csv000
                ) &
            done
            wait
        )

        cat input/raw_$NAME.csv |
        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_weekly.sql
        rm -rf input

        (
            cd output
            
            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv

        )
        Upload cuebiq/$NAME $VERSION
        Upload cuebiq/$NAME latest
        rm -rf output
        Version $PARTNER $NAME $VERSION $NAME
    )
}
