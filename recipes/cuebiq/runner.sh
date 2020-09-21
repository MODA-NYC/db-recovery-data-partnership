#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
VERSION=$DATE
AWS_ACCESS_KEY_ID=$CUEBIQ_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$CUEBIQ_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=us-east-1
TYPE=$1 #mobility/weekly/daily/travelers/relocation
sectors=('automotive' 'dining' 'healthcare' 'lifestyle' 'malls' 'retail' 'telco' 'transportation')

(
  cd $BASEDIR
  mkdir -p output
  mkdir -p input
)

case $TYPE in
    relocation)
    (
        cd $BASEDIR
        NAME=cuebiq_relocation
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
                psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_relocation.sql
                rm -rf input
                 (
                    cd output
                    
                    # Export to CSV
                    psql $RDP_DATA -c "\COPY (
                        SELECT * FROM $NAME.region_outflow
                    ) TO stdout DELIMITER ',' CSV HEADER;" > region_outflow.csv

                    psql $RDP_DATA -c "\COPY (
                        SELECT * FROM $NAME.region_inflow
                    ) TO stdout DELIMITER ',' CSV HEADER;" > region_inflow.csv

                    psql $RDP_DATA -c "\COPY (
                        SELECT * FROM $NAME.nyc_outflow
                    ) TO stdout DELIMITER ',' CSV HEADER;" > nyc_outflow.csv

                    psql $RDP_DATA -c "\COPY (
                        SELECT * FROM $NAME.nyc_inflow
                    ) TO stdout DELIMITER ',' CSV HEADER;" > nyc_inflow.csv

                    # Write VERSION info
                    echo "$VERSION" > version.txt
                )
                Upload cuebiq/$NAME $VERSION
                Upload cuebiq/$NAME latest
                rm -rf output
            );;
            *) echo "$VERSION is already loaded !" ;;
        esac
    )
    ;;
    mobility)
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
    )
    ;;

  weekly)
    (
        cd $BASEDIR
        NAME=cuebiq_weekly

        (
            cd input
            touch raw_$NAME.csv
            for sector in "${sectors[@]}"
            do
                aws s3 cp s3://cuebiq-dataset-nv/offline-intelligence/index=cvi/sector=$sector/country=US/cvi-$sector.csv000.gz cvi-$sector.csv000.gz
                gunzip cvi-$sector.csv000.gz
                tail -n +2 cvi-$sector.csv000 >> raw_$NAME.csv
                rm cvi-$sector.csv000
            done
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
    )
    ;;

  daily)
    (
        cd $BASEDIR
        NAME=cuebiq_daily

        (
            cd input
            for sector in "${sectors[@]}"
            do
                aws s3 cp s3://cuebiq-dataset-nv/offline-intelligence/index=cvi/sector=$sector/country=US/daily-cvi-$sector.csv000.gz \
                    daily-cvi-$sector.csv000.gz &
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
            zip $NAME.zip $NAME.csv
            rm $NAME.csv
            
        )
        Upload cuebiq/$NAME $VERSION
        Upload cuebiq/$NAME latest
        rm -rf output
    )
    ;;

    travelers)
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
    ;;

  *)
    echo -n "
    please specify mobility, weekly, daily, or travelers
    "
    ;;
esac