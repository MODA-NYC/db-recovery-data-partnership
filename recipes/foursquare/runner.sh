#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
ACL=public-read

(
    cd $BASEDIR
    VERSION=$(
        docker run --rm\
            -v $(pwd)/../:/recipes\
            -w /recipes/$NAME\
            python:3.8.5-alpine3.12 sh -c "
                pip install -q --disable-pip-version-check requests bs4
                python asof.py"
        )

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
    Upload $NAME $VERSION $ACL
    Upload $NAME latest $ACL
)
