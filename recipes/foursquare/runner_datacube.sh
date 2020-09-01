#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)

function foursquare_datacube {
    (
        cd $BASEDIR
        NAME=foursquare_datacube
        
        mc cp $GSHEET_CRED creds.json
        mkdir -p input && mkdir -p output

        psql $RDP_DATA -f init.sql

        python3 datacube.py

        if [ "$(ls -A input)" ]; then
            (
                cd input

                for file in $(ls *.tar.gz)
                do
                    max_bg_procs 5
                    (
                        echo $file

                        VERSION=${file%%.*}
                        file_name=$(tar tf $file | grep .csv.gz)
                        tar -xvzf $file $file_name -O > $VERSION.csv.gz
                        
                        gunzip -dc $VERSION.csv.gz | 
                        psql $RDP_DATA \
                            -v NAME=$NAME \
                            -v VERSION=$VERSION \
                            -f ../create_datacube.sql
                        rm $file
                        rm $VERSION.csv.gz
                    ) &
                done
            )

            (
                cd output
                
                VERSION=$(
                    psql $RDP_DATA -At -c "
                    SELECT MAX(table_name::date) 
                    FROM information_schema.tables 
                    where table_schema = 'foursquare_datacube'
                    AND table_name !~* 'latest|main'"
                )

                # Export to CSV
                psql $RDP_DATA -c "\COPY (
                    SELECT * FROM $NAME.latest
                ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv

                psql $RDP_DATA -c "\COPY (
                    SELECT * FROM $NAME.grouped_latest
                ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_datacube_grouped.csv

                psql $RDP_DATA -c "\COPY (
                    SELECT * FROM foursquare_daily_zipcode.latest
                ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_daily_zipcode.csv

                psql $RDP_DATA -c "\COPY (
                    SELECT * FROM foursquare_daily_zipcode.latest
                ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_daily_zipcode_grouped.csv

                psql $RDP_DATA -c "\COPY (
                    SELECT * FROM foursquare_daily_zipcode.latest
                ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_weekly_zipcode.csv

                psql $RDP_DATA -c "\COPY (
                    SELECT * FROM foursquare_daily_zipcode.latest
                ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_weekly_zipcode_grouped.csv

                # Write VERSION info
                echo "$VERSION" > version.txt
            )
            VERSION=$(cat output/version.txt)
            Upload $NAME $VERSION
            Upload $NAME latest
            rm -rf input && rm -rf output
            rm creds.json
        else
            echo "the database is up-to-date!"
            rm -rf input && rm -rf output
            rm creds.json
        fi
    )
}