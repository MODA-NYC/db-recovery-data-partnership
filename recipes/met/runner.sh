#!/bin/bash -e
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE
ACL=private

(
    
    cd $BASEDIR
    rm -rf input && mkdir -p input
    rm -rf output && mkdir -p output


    files=$(axway_ls -nrt Met_Museum_2/Attendance && grep .csv | awk '{print $NF}') || echo 'axway_ls failed'
    output_file="input/attendance_raw.csv"
    for filepath in $files; do
        echo $filepath
        filename=$(basename $filepath)
        echo $filename
        axway_cmd get $filepath input/$filename
        # copy csv without headers
        tail -n +2 input/$filename >> $output_file
    done
    

    files=$(axway_ls -nrt Met_Museum_2/Membership | grep .csv | awk '{print $NF}')
    output_file="input/membership_raw.csv"
    for filepath in $files; do
        echo $filepath
        filename=$(basename $filepath)
        echo $filename
        axway_cmd get $filepath input/$filename
        # copy csv without headers
        tail -n +2 input/$filename >> $output_file
    done


    cat input/attendance_raw.csv |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_attendance.sql

    cat input/membership_raw.csv |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_membership.sql

   
    (
        cd output
        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM met_attendance.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > met_attendance.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM met_attendance_weekly.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > met_attendance_weekly.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM met_membership.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > met_membership.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM met_membership_weekly.\"$VERSION\"
        ) TO stdout DELIMITER ',' CSV HEADER;" > met_membership_weekly.csv

        # Write VERSION info
        echo "$VERSION" > version.txt
        
    )

    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf input && rm -rf output
    Version $NAME '' $VERSION $NAME
)
