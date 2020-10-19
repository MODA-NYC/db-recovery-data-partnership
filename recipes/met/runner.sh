#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE
ACL=private

(
    
    cd $BASEDIR
    rm -rf input && mkdir -p input
    rm -rf output && mkdir -p output

    rm -rf input/attendance_raw.csv

    files=$(axway_ls -nrt Met_Museum/Attendance | grep .csv | awk '{print $NF}')
    i=0
    output_file="input/attendance_raw.csv"
    for filename in $files; do
        echo $i
        echo $filename
        axway_cmd get $filename input/$filename
        if [[ $i -eq 0 ]] ; then
            # copy csv headers from first file
            head -1 $filename > $output_file
        fi
        # copy csv without headers from other files
        tail -n +2 $filename >> $output_file
        i=$(( $i + 1 ))
    done
    
    rm -rf input/attendance_raw.csv

    files=$(axway_ls -nrt Met_Museum/Membership | grep .csv | awk '{print $NF}')
    i=0
    output_file="input/membership_raw.csv"
    for filename in $files; do
        echo $i
        echo $filename
        axway_cmd get $filename input/$filename
        if [[ $i -eq 0 ]] ; then
            # copy csv headers from first file
            head -1 $filename > $output_file
        fi
        # copy csv without headers from other files
        tail -n +2 $filename >> $output_file
        i=$(( $i + 1 ))
    done


    cat input/attendance_raw.csv |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_attendance.sql

    cat input/membership_raw.csv |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_membership.sql

   
    (
        cd output
        # Export to CSV
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM met_attendance.latest
        ) TO stdout DELIMITER ',' CSV HEADER;" > met_attendance.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM met_attendance_weekly.latest
        ) TO stdout DELIMITER ',' CSV HEADER;" > met_attendance_weekly.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM met_membership.latest
        ) TO stdout DELIMITER ',' CSV HEADER;" > met_membership.csv

        psql $RDP_DATA -c "\COPY (
            SELECT * FROM met_membership_weekly.latest
        ) TO stdout DELIMITER ',' CSV HEADER;" > met_membership_weekly.csv

        # Write VERSION info
        echo "$VERSION" > version.txt
        
    )

    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf input && rm -rf output
    Version $NAME '' $VERSION $NAME
)
