#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
PARTNER=$(basename $BASEDIR)
AWS_ACCESS_KEY_ID=$CUEBIQ_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$CUEBIQ_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=us-east-1

function cuebiq_homeswitcher {
    (
        cd $BASEDIR
        NAME=cuebiq_homeswitcher
        KEY=$(aws s3 ls s3://cuebiq-dataset-nv/offline-intelligence/index=relocation/country=US/ --recursive | sort | tail -n 1 | awk '{print $4}')
        FILENAME=$(basename $KEY)
        RAWDATE=$(echo "$FILENAME" | sed -e "s/^ri-//" -e "s/.csv000.gz$//")
        VERSION=$(date -d "$RAWDATE" +%Y-%m-%d)
        LOADED=$(psql -q -At $RDP_DATA -c "
            SELECT '$VERSION' IN (
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = '$NAME'
            )")
        case $LOADED in
            f)
            (
                aws s3 cp s3://cuebiq-dataset-nv/$KEY input/$FILENAME
                gzip -dc input/$FILENAME |
                psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_homeswitcher.sql
                rm -rf input
                 (
                    cd output
                    
                    # Export to CSV
                    psql $RDP_DATA -c "\COPY (
                        SELECT * FROM $NAME.\"$VERSION\"
                    ) TO stdout DELIMITER ',' CSV HEADER;" > cuebiq_weekly_homeswitcher.csv

                    # Write VERSION info
                    echo "$VERSION" > version.txt
                )
                Upload cuebiq/$NAME $VERSION
                Upload cuebiq/$NAME latest
                rm -rf output
                Version $PARTNER $NAME $VERSION $NAME
            );;
            *) echo "$VERSION is already loaded !" ;;
        esac
    )
}
