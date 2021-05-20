#!/bin/bash
source $(pwd)/bin/config.sh

BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


AWS_DEFAULT_REGION=us-east-1

(      
    
    cd $BASEDIR
    rm -rf input
    mkdir -p input
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
    echo 'downloading from mastercard'
    scp -P 22022 -i /root/.ssh/id_rsa_axway -o "StrictHostKeyChecking=no" newyorkcity@files.mastercard.com:geoinsights/data/fromMC/* ./input
    #For testing purposes
    #cp Geogrids_NYC_Zip_Codes_Level_01Jan2019_25Apr2021_Final.zip input/

    #upload files to aws for backup. Can handle multiple files.: 
    #getting InvalidAccessKeyIDError. Commented out until resolved.
    echo 'uploading to RDP AWS S3'
    aws s3 cp ./input/ s3://recovery-data-partnership/mastercard/ --recursive || AWS_ERROR=1

    #loop through all the files and add each to output
    echo 'listing...'
    MYFILES=$(ls input | grep .zip)
    echo "MYFILES:" $MYFILES
    mkdir -p output
    for FULL_FILENAME in $MYFILES
        do 
        #loop begins
        
        FILENAME=${FULL_FILENAME%.*}


        pushd input
        rm *.csv || echo "Failed to remove any csvs"
        popd
        echo "unzipping " $FULL_FILENAME
        unzip -d ./input -P $MASTERCARD_PASSWORD ./input/$FULL_FILENAME || exit 519

  
        #find the csv. There should only be one.
        pushd input
        CSV_FILENAME=$(ls *.csv)
        #CSV_FILENAME=$(ls | egrep '\.csv')
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

     if [ "$AWS_ERROR" -eq 1 ]
        then
            echo "Sharepoint upload successfull but AWS upload failed.";
            exit 435;
        fi
)
