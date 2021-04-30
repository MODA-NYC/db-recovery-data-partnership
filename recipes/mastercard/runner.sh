#!/bin/bash
source $(pwd)/bin/config.sh

BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


(      
    cd $BASEDIR
    mkdir -p input
    mkdir -p output
    chmod 777 input
    
    #For testing purposes
    #cp Geogrids_NYC_Zip_Code_Level_Jan2019_Feb2021.zip input/

    #will download all files from mastercard. Then mastercard will delete after successfull download.
    scp -v -P 22022  -i /root/.ssh/id_rsa_axway -o "StrictHostKeyChecking=no" newyorkcity@files.mastercard.com:geoinsights/data/fromMC/* /input
    echo 'file is ' $(find $BASEDIR/input -name "*.zip" ) 
    unzip -d /input -P $MASTERCARD_PASSWORD $(find $BASEDIR/input -name "*.zip" | head -1 ) 
    rm $(find $BASEDIR/input -name "*.zip")
    #cd $BASEDIR

    #find the filename. Assumes one file. (all compressed files removed, and head selects ony one file,
    # so there should only be on csv found)
    KEY=$(ls /input)
    FILENAME=$(basename $KEY)
    echo $FILENAME

    #upload file to aws: InvalidAccessKeyId error, AWS access key already assigned to the digital ocean account. Need to switch accounts.
    #aws s3 cp /input/$KEY s3://recovery-data-partnership/mastercard/
    
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
    #can to split the CSVs, but makes a mess.
    #cat output/mastercard.csv | python3 split_csv.py
    
    #unsplit csv is too large. Must compress.
    zip -9 output/mastercard_$DATE.zip output/mastercard.csv
    
    #If you don't remove unsplit csv, sharepoint.py will overflow the RAM and the process killed when it tries to upload it.
    #Upload uploads everything in the output folder.
    rm -rf output/mastercard.csv
    
    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
    Version $NAME '' $VERSION $NAME
)
