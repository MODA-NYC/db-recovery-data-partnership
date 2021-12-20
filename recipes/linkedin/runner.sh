#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE

# install new dependency
# added to requirements.txt also, but it won't work until the docker image is rebuilt
pip install openpyxl

(
    cd $BASEDIR
    mkdir -p output
    mkdir -p input

    latest_file=$(axway_ls -nrt LinkedIn | grep .xlsx | tail -1 | awk '{print $NF}') || echo 'axway_ls failed on LinkedIn'
    echo "$latest_file"
    rm -rf input/raw.xlsx
    axway_cmd get $latest_file input/raw.xlsx

    python3 build.py | throw |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql
    rm -rf input

    (
        cd output

        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM linkedin.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > linkedin_nyc_hiringrate.csv

        # Write VERSION info
        echo "$VERSION" > version.txt
    )
    
    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
    Version $NAME '' $VERSION $NAME
)
