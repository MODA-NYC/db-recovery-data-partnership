#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE
ACL=private

(
    
    cd $BASEDIR
    mkdir -p input
    mkdir -p output

    latest_file=$(axway_ls -nrt Ioby/donation | grep .xlsx | tail -1 | awk '{print $NF}')
    echo "$latest_file"
    rm -rf input/donations_raw.xlsx
    axway_cmd get $latest_file input/donations_raw.xlsx

    latest_file=$(axway_ls -nrt Ioby/ideas | grep .xlsx | tail -1 | awk '{print $NF}')
    echo "$latest_file"
    rm -rf input/ideas_raw.xlsx
    axway_cmd get $latest_file input/ideas_raw.xlsx

    latest_file=$(axway_ls -nrt Ioby/il4s | grep .xlsx | tail -1 | awk '{print $NF}')
    echo "$latest_file"
    rm -rf input/il4_raw.xlsx
    axway_cmd get $latest_file input/il4_raw.xlsx

    python3 build.py |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql

   
    (
        cd output
        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM ioby_active_projects.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > ioby_active_projects.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM ioby_potential_projects.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > ioby_potential_projects.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM ioby_active_projects.count_by_zip
        ) TO stdout DELIMITER ',' CSV HEADER;" > ioby_count_by_zip.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM ioby_donations.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > ioby_weekly_count_by_zip.csv

        # Export to ShapeFile
        SHP_export $RDP_DATA ioby_active_projects.count_by_zip MULTIPOLYGON ioby_count_by_zip
        SHP_export $RDP_DATA ioby_donations.$VERSION MULTIPOLYGON ioby_weekly_count_by_zip

        # Write VERSION info
        echo "$VERSION" > version.txt
        
    )

    Upload $NAME $VERSION
    Upload $NAME latest
)
