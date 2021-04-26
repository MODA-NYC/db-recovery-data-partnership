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
   
    scp newyorkcity@files.mastercard.com:geoinsights/data/fromMC/* /input
    unzip -P $MASTERCARD_PASSWORD $(find $BASEDIR/input -name "*.zip" | head -1 )
    cd $BASEDIR 
    
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
    #can to split the CSVs. Makes a mess.
    #cat output/mastercard.csv | python3 split_csv.py
    
    #unsplit csv is too large. Must compress.
    zip -9 output/mastercard_$DATE.zip output/mastercard.csv
    
    #If you don't remove unsplit csv, sharepoint.py will overflow the RAM and the process killed.
    rm -rf output/mastercard.csv
    
    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
    Version $NAME '' $VERSION $NAME
) 
