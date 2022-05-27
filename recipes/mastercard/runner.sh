#!/bin/bash
source $(pwd)/bin/config.sh

BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


AWS_DEFAULT_REGION=us-east-1

(   
    cd $BASEDIR
    pip install boto3
    #clean up input if already exists because job did not complete. IF remove fails, do nothing (:).
    rm -rf input || :
    mkdir -p input
    #was having trouble writing to input. Input directory is temporary and will not persist.
    chmod 777 input
    #check to verify there is a file on the mastercard server.
    #Files will not download and delete unless there is at least one zip file. 
    #decision to not check for single file.
    #comment out for texting

    echo 'assiging rowcount'
    #need to connect to proxy
    #ROWCOUNT=$(echo 'ls -l' | sftp -q -oPort=22022 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_axway newyorkcity@files.mastercard.com:geoinsights/data/fromMC | grep .zip | wc -l)
    #MASTERCARD_LS=$(curl -v --insecure -x $PROXY_IP -u "newyorkcity": --key ~/.ssh/id_rsa_axway --pubkey ~/.ssh/id_rsa.pub  sftp://files.mastercard.com:22022/geoinsights/data/fromMC/ -l | grep ".zip")
    MASTERCARD_LS=$(curl -v --insecure -u "newyorkcity": --key ~/.ssh/id_rsa_axway --pubkey ~/.ssh/id_rsa.pub  sftp://files.mastercard.com:22022/geoinsights/data/fromMC/ -l | grep ".zip")

    ROWCOUNT=$(echo $MASTERCARD_LS | wc -l)
    
    #ROWCOUNT=1
    echo 'rowcount ' $ROWCOUNT

    if [ $ROWCOUNT -lt 1 ];

    then 
        echo "Error: There are no zip files on the Mastercard sftp server.";
        exit 3
    fi
    
    #will download all files from mastercard. Then mastercard will delete after successfull download. May be more than one file without check.
    echo 'downloading from mastercard'
    #scp -P 22022 -i ~/.ssh/id_rsa_axway -o "StrictHostKeyChecking=no" newyorkcity@files.mastercard.com:geoinsights/data/fromMC/* ./input
    #For testing purposes 
    #cp test_data.zip input/
    
    for FILENAME in $MASTERCARD_LS
        do
            #removed -x $IP_PROXY
             $(curl -v --insecure -u "newyorkcity":  --key ~/.ssh/id_rsa_axway --pubkey ~/.ssh/id_rsa.pub  sftp://files.mastercard.com:22022/geoinsights/data/fromMC/$FILENAME --output ./input/$FILENAME)

    done
    
    
    #upload files to aws for backup. Can handle multiple files.: 
    #getting InvalidAccessKeyIDError. Commented out until resolved.
    echo 'uploading to RDP AWS S3'
    AWS_ERROR=0
    aws s3 cp ./input/ s3://recovery-data-partnership/mastercard/ --recursive || AWS_ERROR=1
    
    echo 'listing...'
    #this lists all zip files
    #MYFILES=$(ls ./input | grep .zip)
    #Change, removed '| tail -n 1'. So now there may be multiple files.
    MYFILES=$(ls ./input -tr | grep .zip)
    echo "MYFILES:" $MYFILES
    mkdir -p output
    for FULL_FILENAME in $MYFILES
        do 
        #loop begins (should be a list of one)
        #take the base name of the full filename (drop suffix)
        FILENAME=${FULL_FILENAME%.*}

        #goes into input directory and removes any csvs. Then unzip one csv into input. We will unzip and process each csv one at a time.
        pushd input
        rm *.csv || echo "Failed to remove any csvs"
        
        echo "unzipping " $FULL_FILENAME
        unzip -P $MASTERCARD_PASSWORD $FULL_FILENAME || exit 519
        
        #find the csv. There should only be one because you greped the tail.
        CSV_FILENAME=$(ls *.csv)
        popd
        #send csv to PSQL
        #no db available in github
        #cat ./input/$CSV_FILENAME | psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_mastercard.sql
        
        #create a new fileneame based on start and end dates.
        NEW_FILENAME=$(python create_filename.py ./input/$FULL_FILENAME)
        #no network, no db.
        #(
        #psql $RDP_DATA -c "\COPY (
        #    SELECT * FROM $NAME.\"$VERSION\"
        #    ) TO stdout DELIMITER ',' CSV HEADER;" > ./output/$NEW_FILENAME.csv
        
        #Write Version info
        #echo "version: " $VERSION
        echo "$VERSION_$NEW_FILENAME" >> ./output/version.txt
        
    
        #don't need to compress anymore

        #before you close, upload a copy to AWS
        aws s3 cp output/$NEW_FILENAME.csv s3://recovery-data-partnership/mastercard_processed/$NEW_FILENAME.csv || AWS_ERROR=1

    done
    #loop ends

    #save S3 DB to csv. 
    python save_mastercard_master_csv.py
  
    #uploading all the files to all data. Assumes the program has previously saved the other files into output directory. 
    #comment out because no sharepoint
    #Upload $NAME all_data
    
    # this will not work because filename not defined (part of loop)
    #mv ./output/daily_transactions_$FILENAME.zip ./output/mastercard_latest.zip
    
    #list all csvs, find the latest, and rename them to 'mastercard_latest'
    #the latest is named in alphabetical order from python. just need the last one
    cd output
    #mv $(find . -name '*.csv' -print0 | xargs -0 ls -1 -t | head -1) mastercard_latest.csv
    mv $(find . -name '*.csv' -print0 | xargs -0 ls -1 -r | head -1) mastercard_latest.csv
    #remove all files that do not match the latest or version.
    find . -type f -not -name 'mastercard_latest.csv' -not -name 'version.txt' -delete

    cd ..
    #no sharepoint in github hosted runner
    #Upload $NAME latest

    rm -rf output
    Version $NAME '' $VERSION $NAME
    rm -rf input

    if [ "$AWS_ERROR" -eq 1 ]
    then
        echo "Sharepoint upload successful but AWS upload failed.";
        exit 435;
    fi
)
