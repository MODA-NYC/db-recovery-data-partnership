#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
TYPE=$1 # datacube/*

function foursquare_default {
    (
        cd $BASEDIR

        if [ -z "$VERSION" ]
        then
            # If VERSION is not set, then run asof.py to get version
            VERSION=$(python3 asof.py)
        else
            # If VERSION is set, then ignore asof.py (this is for github actions)
            echo "$VERSION is set!"
        fi
        
        echo "pulling version: $VERSION"

        mkdir -p input && (
            cd input
            curl -o NY.csv https://data.visitdata.org/processed/vendor/foursquare/asof/$VERSION/NewYork_NewYork.csv &
            curl -o QN.csv https://data.visitdata.org/processed/vendor/foursquare/asof/$VERSION/NewYork_Queens.csv &
            curl -o BX.csv https://data.visitdata.org/processed/vendor/foursquare/asof/$VERSION/NewYork_BronxCounty.csv &
            curl -o BK.csv https://data.visitdata.org/processed/vendor/foursquare/asof/$VERSION/NewYork_Brooklyn.csv &
            curl -o SI.csv https://data.visitdata.org/processed/vendor/foursquare/asof/$VERSION/NewYork_StatenIsland.csv

            wait 
            cat NY.csv > raw.csv
            tail -n +2 QN.csv >> raw.csv
            tail -n +2 BX.csv >> raw.csv
            tail -n +2 BK.csv >> raw.csv
            tail -n +2 SI.csv >> raw.csv

            ls | grep -v raw.csv | xargs rm 
        )

        cat input/raw.csv | psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql
        rm -rf input

        mkdir -p output && 
        (
            cd output

            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv

            psql $RDP_DATA -c "\COPY (
                SELECT * FROM foursquare_grouped.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_grouped.csv

            # Write VERSION info
            echo "$VERSION" > version.txt
            
        )
        Upload $NAME $VERSION
        Upload $NAME latest
        rm -rf output
    )
}

function foursquare_datacube {
    (
        cd $BASEDIR
        NAME=foursquare_datacube
        
        mc cp $GSHEET_CRED creds.json
        mkdir -p input && mkdir -p output

        python3 datacube.py

        (
            cd input
            file_name=$(tar tf *.tar.gz | grep .csv.gz)
            path=$(dirname $file_name)
            VERSION=${path: -10}
            tar -xvzf *.tar.gz $file_name -O > raw.csv.gz
            echo "$VERSION" > version.txt
        )

        VERSION=$(cat input/version.txt)
        gunzip -dc input/raw.csv.gz | 
        psql $RDP_DATA \
            -v NAME=$NAME \
            -v VERSION=$VERSION \
            -f create_datacube.sql
        
        (
            cd output
            
            # Export to CSV
            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > $NAME.csv

            psql $RDP_DATA -c "\COPY (
                SELECT * FROM $NAME.latest
            ) TO stdout DELIMITER ',' CSV HEADER;" > foursquare_datacube_nyc.csv

            # Write VERSION info
            echo "$VERSION" > version.txt
        )

        Upload $NAME $VERSION
        Upload $NAME latest
        rm -rf output && rm -rf output
        rm creds.json
    )
}

case $TYPE in
    datacube)
        # updating foursquare datacube
        foursquare_datacube
    ;;
    *)
        # Default pulling county level foursquare data
        foursquare_default
    ;;
esac