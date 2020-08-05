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

        # Export to ShapeFile
        SHP_export $RDP_DATA ioby_active_projects.count_by_zip MULTIPOLYGON ioby_count_by_zip

        # Write VERSION info
        echo "$VERSION" > version.txt
        
    )

    Upload $NAME $VERSION $ACL
    Upload $NAME latest $ACL
)
