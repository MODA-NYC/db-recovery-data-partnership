#!/bin/bash
source $(pwd)/bin/config.sh

BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


(      
    cd $BASEDIR
    mkdir -p input
    mkdir -p output

    #was having trouble writing to input.
    chmod 777 input
    
    #For testing purposes
    cp Geogrids_NYC_Zip_Code_Level_Jan2019_Feb2021.zip input/
   
    #check to verify there is only one file on the mastercard server. 
    #Files will not download and delete unless there is only one zip file. 
    #comment out for texting
    ROWCOUNT=$(echo 'ls -l' | sftp -q -oPort=22022 -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa_axway newyorkcity@files.mastercard.com:geoinsights/data/fromMC | grep .zip | wc -l)
    #ROWCOUNT=1
    echo 'rowcount ' $ROWCOUNT
    if [ $ROWCOUNT -gt 1 ];

    then 
        echo "Error: There are more than one zip file on the Mastercard sftp server.";
        exit 4
    fi

    if [ $ROWCOUNT -lt 1 ];

    then 
        echo "Error: There are no zip files on the Mastercard sftp server.";
        exit 3
    fi

    #will download all files from mastercard (there has already been a check to verify there is one and only one zip file). Then mastercard will delete after successfull download.
    scp -P 22022  -i /root/.ssh/id_rsa_axway -o "StrictHostKeyChecking=no" newyorkcity@files.mastercard.com:geoinsights/data/fromMC/* /input
    
    #verify the correct file
    echo "unzipping " $( ls -ltr input | tail -1 | awk '{print $NF}') 
    #unzips the first file by chronological order by sorting by modified date, reversed, and taking the tail to avoid the header
    # (there is a check above to ensure there is only be one zip file so sorting is redundant).
    # Then use awk to select filename.
    unzip -d /input -P $MASTERCARD_PASSWORD $( ls -ltr input | tail -1 | awk '{print $NF}') 
    #removes all downloaded non-csv files.
    rm $(find $BASEDIR/input -type f -not -name "*.csv")
    #cd $BASEDIR

    #find the filename. Should only be one file. 
    KEY=$(ls /input)
    FILENAME=$(basename $KEY)
    echo $FILENAME

    #upload file to aws: InvalidAccessKeyId error.
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
    
    #unsplit csv is too large. Must compress.
    zip -9 output/mastercard_$DATE.zip output/mastercard.csv
    
    #If you don't remove unsplit csv, sharepoint.py will overflow the RAM and the process killed when it tries to upload it.
    rm -rf output/mastercard.csv

    #Upload uploads everything in the output folder.
    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
    Version $NAME '' $VERSION $NAME
)
