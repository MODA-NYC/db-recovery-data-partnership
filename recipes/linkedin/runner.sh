#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE

(
    cd $BASEDIR
    mkdir -p output
    mkdir -p input

    python3 build.py |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql

    (
        cd output

        echo '*' > .gitignore
           
        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM linkedin.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > linkedin.csv

        # Write VERSION info
        echo "$VERSION" > version.txt
    )
)
