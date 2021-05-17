#!/bin/bash
source $(pwd)/bin/config.sh

BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


AWS_DEFAULT_REGION=us-east-1



(      
    cd $BASEDIR
    mkdir -p input
    mkdir -p output
    #was having trouble writing to input. Input directory is temporary and will not persist.
    chmod 777 input
    
    #check to verify there is a file on the mastercard server.
    #Files will not download and delete unless there is at least one zip file. 
    #decision to not check for single file.
    #comment out for texting
    ROWCOUNT=$(echo 'ls -l' | sftp -q -oPort=22022 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_axway newyorkcity@files.mastercard.com:geoinsights/data/fromMC | grep .zip | wc -l)
    
    #bypass check for one file. 
    #Uncomment for testing.
    #ROWCOUNT=1

    echo 'rowcount ' $ROWCOUNT
    
    #decision to proceed even if multiple files
    
    #if [ $ROWCOUNT -gt 1 ];
    #
    #then 
    #    echo "Error: There are more than one zip file on the Mastercard sftp server.";
    #    exit 4
    #fi

    #will still throw error if no zip files

    if [ $ROWCOUNT -lt 1 ];

    then 
        echo "Error: There are no zip files on the Mastercard sftp server.";
        exit 3
    fi

    #will download all files from mastercard. Then mastercard will delete after successfull download. May be more than one file without check.
    scp -P 22022  -i /root/.ssh/id_rsa_axway -o "StrictHostKeyChecking=no" newyorkcity@files.mastercard.com:geoinsights/data/fromMC/* /input
    #For testing purposes
    #cp Geogrids_NYC_Zip_Codes_Level_01Jan2019_25Apr2021_Final.zip input/

    #upload files to aws for backup. Can handle multiple files.: 
    #getting InvalidAccessKeyIDError. Commented out until resolved.
    aws s3 cp ./input/ s3://recovery-data-partnership/mastercard/ --recursive

    #verify the correct file
    FULL_FILENAME=$( ls -ltr input | tail -1 | awk '{print $NF}') 
    echo "unzipping " $FULL_FILENAME
    #unzips the first file by chronological order by sorting by modified date, reversed, and taking the tail to avoid the header
    # Then use awk to select filename.
    unzip -d /input -P $MASTERCARD_PASSWORD $FULL_FILENAME
    #removes all downloaded non-csv files.
    rm $(find $BASEDIR/input -type f -not -name "*.csv")
    #cd $BASEDIR

    #find the filename. Should only be one file. 
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
    
    #unsplit csv is too large. Must compress.
    echo "compressing mastercard.csv"
    zip -9 output/daily_transactions.zip output/mastercard.csv
    
    #If you don't remove unsplit csv, sharepoint.py will overflow the RAM and the process killed when it tries to upload it.
    rm -rf output/mastercard.csv

    #Upload uploads everything in the output folder.
    Upload $NAME $VERSION
    Upload $NAME latest
    rm -rf output
    Version $NAME '' $VERSION $NAME
)
