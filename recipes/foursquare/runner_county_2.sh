#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
PARTNER=$(basename $BASEDIR)

function foursquare_county_2 {
    (
        pip install sqlalchemy
        cd $BASEDIR
        NAME=foursquare_county
        
        mc cp $GSHEET_CRED creds.json
        mkdir -p input && mkdir -p output

        psql $RDP_DATA -f init.sql
        
        python3 datacube.py county
        
        #if [ -z "$VERSION" ]
        #then
            # If VERSION is not set, then run asof.py to get version. But asofpy deprecated.
            #get version later
        #fi
        
        

        if [ "$(ls -A input)" ]; then
            (
                cd input

                for file in $(ls *.tar.gz)
                do
                    max_bg_procs 5
                    (
                        echo $file

                        VERSION=${file%%.*}
                        echo "Version:" $file
                        file_name=$(tar tf $file | grep .csv.gz)
                        tar -xvzf $file $file_name -O > $VERSION.csv.gz
                        
                        gunzip -dc $VERSION.csv.gz | 
                        psql $RDP_DATA \
                            -v NAME=$NAME \
                            -v VERSION=$VERSION \
                            -f ../create_county_2.sql
                        rm $file
                        rm $VERSION.csv.gz
                    )  & # the ampersand makes it run asynchronously
                done
                wait
            )

            (
                cd output
                   
            # Export to CSV
            #psql $RDP_DATA -c "\COPY (
            #    SELECT * FROM $NAME.daily_county
            #) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_latest_daily_county.csv

            #psql $RDP_DATA -c "\COPY (
            #    SELECT * FROM $NAME.weekly_county
            #) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_latest_weekly_county.csv
            
        
            psql $RDP_DATA -c "\COPY (
                    SELECT * FROM $NAME.main_county_daily
            ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_daily_county.csv

            psql $RDP_DATA -c "\COPY (
                    SELECT * FROM $NAME.main_county_weekly
            ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_weekly_county.csv
            
            # Write VERSION info
            echo "$VERSION" > version_county.txt
            
            )
            VERSION=$(cat output/version_county.txt)
            Upload foursquare/$NAME $VERSION
            Upload foursquare/$NAME latest
            Version $PARTNER $NAME $VERSION $NAME
            rm -rf input && rm -rf output
            rm creds.json
        else
            echo "the database is up-to-date!"
            rm -rf input && rm -rf output
            rm creds.json
        fi
    )
}
