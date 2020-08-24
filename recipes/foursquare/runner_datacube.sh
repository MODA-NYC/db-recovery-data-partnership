#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)

function foursquare_datacube {
    (
        cd $BASEDIR
        NAME=foursquare_datacube
        
        # mc cp $GSHEET_CRED creds.json
        mkdir -p input && mkdir -p output

        # python3 datacube.py

        (
            cd input

            for file in $(ls *.tar.gz)
            do
                echo $file

                VERSION=${file%%.*}
                file_name=$(tar tf $file | grep .csv.gz)
                tar -xvzf $file $file_name -O > $VERSION.csv.gz
                
                gunzip -dc $VERSION.csv.gz | 
                psql $RDP_DATA \
                    -v NAME=$NAME \
                    -v VERSION=$VERSION \
                    -f ../create_datacube.sql
            done
        )

        # (
        #     cd output
            
        #     # Export to CSV
        #     psql $RDP_DATA -c "\COPY (
        #         SELECT * FROM $NAME.\"$VERSION\"
        #     ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv

        #     psql $RDP_DATA -c "\COPY (
        #         SELECT * FROM $NAME.latest
        #     ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_datacube_nyc.csv

        #     # Write VERSION info
        #     echo "$VERSION" > version.txt
        # )

        # Upload $NAME $VERSION
        # Upload $NAME latest
        # rm -rf output && rm -rf output
        # rm creds.json
    )
}
