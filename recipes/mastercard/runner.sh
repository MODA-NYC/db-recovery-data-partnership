#!/bin/bash
source $(pwd)/bin/config.sh

BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


AWS_DEFAULT_REGION=us-east-1

(      
    
    cd $BASEDIR
    #clean up input if already exists because job did not complete. IF remove fails, do nothing (:).
    rm -rf input || :
    mkdir -p input
    #was having trouble writing to input. Input directory is temporary and will not persist.
    chmod 777 input
    
    #check to verify there is a file on the mastercard server.
    #Files will not download and delete unless there is at least one zip file. 
    #decision to not check for single file.
    #comment out for texting
    ROWCOUNT=$(echo 'ls -l' | sftp -q -oPort=22022 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_axway newyorkcity@files.mastercard.com:geoinsights/data/fromMC | grep .zip | wc -l)
    echo 'rowcount ' $ROWCOUNT

    if [ $ROWCOUNT -lt 1 ];

    then 
        echo "Error: There are no zip files on the Mastercard sftp server.";
        exit 3
    fi

    #will download all files from mastercard. Then mastercard will delete after successfull download. May be more than one file without check.
    echo 'downloading from mastercard'
    scp -P 22022 -i /root/.ssh/id_rsa_axway -o "StrictHostKeyChecking=no" newyorkcity@files.mastercard.com:geoinsights/data/fromMC/* ./input
    #For testing purposes
    #cp Geogrids_NYC_Zip_Codes_Level_01Jan2019_25Apr2021_Final.zip input/

    #upload files to aws for backup. Can handle multiple files.: 
    #getting InvalidAccessKeyIDError. Commented out until resolved.
    echo 'uploading to RDP AWS S3'
    aws s3 cp ./input/ s3://recovery-data-partnership/mastercard/ --recursive || AWS_ERROR=1

    
    echo 'listing...'
    #MYFILES=$(ls input | grep .zip)
    #take the latest zip file.
    MYFILES=$(ls -tr | grep .zip | tail -n 1)
    echo "MYFILES:" $MYFILES
    mkdir -p output
    for FULL_FILENAME in $MYFILES
        do 
        #loop begins
        #take the base name of the full filename (drop suffix)
        FILENAME=${FULL_FILENAME%.*}

        #goes into input directory and removes any csvs. Then unzip one csv into input. We will unzip and process each csv one at a time.
        pushd input
        rm *.csv || echo "Failed to remove any csvs"
        popd
        echo "unzipping " $FULL_FILENAME
        unzip -d ./input -P $MASTERCARD_PASSWORD ./input/$FULL_FILENAME || exit 519

  
        #find the csv. There should only be one.
        pushd input
        CSV_FILENAME=$(ls *.csv)
        popd
        #send csv to PSQL
        cat ./input/$CSV_FILENAME | psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_mastercard.sql
        

        (
        psql $RDP_DATA -c "\COPY (
            SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > ./output/mastercard_$FILENAME.csv
        
        #Write Version info
        echo "version: " $VERSION
        echo "$VERSION_$FILENAME" >> ./output/version.txt
        )
    
        #unsplit csv is too large. Must compress.
        echo "compressing mastercard_$FILENAME.csv"
        zip -9 ./output/daily_transactions_$FILENAME.zip output/mastercard_$FILENAME.csv
    
        #If you don't remove unsplit csv, sharepoint.py will overflow the RAM and the process killed when it tries to upload it.
        rm -rf output/mastercard_$FILENAME.csv       
    done
    #loop ends

    #Upload uploads everything in the output folder.
    Upload $NAME $VERSION
    Upload $NAME latest
    Version $NAME '' $VERSION $NAME
    rm -rf output
    rm -rf input

    if [ "$AWS_ERROR" -eq 1 ]
    then
        echo "Sharepoint upload successfull but AWS upload failed.";
        exit 435;
    fi
)
