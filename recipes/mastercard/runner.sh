#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


(      
    cd $BASEDIR
    mkdir -p input
    mkdir -p output

    
    #For testing purposes
    #unzip -d /input -P $MASTERCARD_PASSWORD $(find $BASEDIR -name "*.zip" |
    #head -1 ) 

    #will download all files from mastercard. Then mastercard will delete after successfull download.
    sftp -oPort=22022 -o StrictHostKeyChecking=no -b sftp-commands.txt newyorkcity@files.mastercard.com:geoinsights/data
   
    #find the filename. Assumes one file.
    KEY=$(ls /input)
    FILENAME=$(basename $KEY)
    echo $FILENAME
    #send csv to PSQL
    cat /input/$FILENAME | psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_mastercard.sql
    #clean up
    rm -rf input
    (
        cd output
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > mastercard.csv
        
        #Write Version info
        echo "$VERSION" > version.txt
    )
    #csv is too large. Must compress.
    gzip output/mastercard.csv
    #Upload mastercard/$NAME $VERSION
    
    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
    Version $NAME '' $VERSION $NAME
) 
