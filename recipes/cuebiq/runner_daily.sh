#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
PARTNER=$(basename $BASEDIR)
AWS_ACCESS_KEY_ID=$CUEBIQ_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$CUEBIQ_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=us-east-1
sectors=('automotive' 'dining' 'healthcare' 'lifestyle' 'malls' 'retail' 'telco' 'transportation')

function cuebiq_daily {
    (
        cd $BASEDIR
        NAME=cuebiq_daily
        export VERSION=$(aws s3 ls --recursive s3://cuebiq-dataset-nv/offline-intelligence/index=cvi/sector=malls/country=US/ | tail -n 1 | awk '{print $1}')
        echo "version"
        echo $VERSION

        (
            cd input 
            ls 
            for sector in "${sectors[@]}"
            do
                KEY=$(aws s3 ls --recursive s3://cuebiq-dataset-nv/offline-intelligence/index=cvi/sector=$sector/country=US/ | sort | awk '{print $4}'| grep 'vdate=*' | grep 'daily-*' | tail -n 1 )
                TARGET_FILENAME=daily-cvi-$sector.csv000.gz
                aws s3 cp s3://cuebiq-dataset-nv/$KEY $TARGET_FILENAME &
            done
            wait
        )
        
        psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_daily.sql
        rm -rf input
        
        (
            cd output
            
            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv
            zip -9 cuebiq_daily_visits.zip $NAME.csv
            rm $NAME.csv
            
            # Write VERSION info
            echo "$VERSION" > version.txt
            
        )
        Upload cuebiq/$NAME $VERSION
        Version $PARTNER $NAME $VERSION $NAME
        rm -rf output
    )   
}
