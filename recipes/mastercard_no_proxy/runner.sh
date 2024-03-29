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
    #need to connect outside proxy
    #to build libcurl with sftp support: https://bugs.launchpad.net/ubuntu/+source/curl/+bug/311029
    MASTERCARD_LS=$(curl -v --insecure --key ~/.ssh/id_rsa_axway -u "newyorkcity": --pubkey ~/.ssh/id_rsa.pub  sftp://files.mastercard.com:22022/geoinsights/data/fromMC/ -l | grep ".zip")
    ROWCOUNT=$(echo $MASTERCARD_LS | wc -l)
    
    #for testing
    #ROWCOUNT=1
    echo 'rowcount ' $ROWCOUNT

    if [ $ROWCOUNT -lt 1 ];

    then 
        echo "Error: There are no zip files on the Mastercard sftp server.";
        exit 3
    fi
    
    #will download all files from mastercard. Then mastercard will delete after successfull download. May be more than one file without check.
    echo 'downloading from mastercard'
        
    #For testing purposes 
    #cp test_data2.zip ./input/test_data2.zip
    
    for FILENAME in $MASTERCARD_LS
        do
             $(curl -v --insecure -u "newyorkcity": --key ~/.ssh/id_rsa_axway --pubkey ~/.ssh/id_rsa.pub  sftp://files.mastercard.com:22022/geoinsights/data/fromMC/$FILENAME --output ./input/$FILENAME)
             #echo "Testing"
    done
    
    
    #upload files to aws for backup. Can handle multiple files.: 
    #getting InvalidAccessKeyIDError. Commented out until resolved.
    echo 'uploading to RDP AWS S3'

    aws s3 cp --recursive --region $AWS_DEFAULT_REGION ./input/ s3://recovery-data-partnership/mastercard/ 
    echo 'listing...'
    #this lists all zip files
    #MYFILES=$(ls ./input | grep .zip)
    #Change, removed '| tail -n 1'. So now there may be multiple files.
    MYFILES=$(ls ./input -tr | grep .zip) || echo "error listing files"
    echo "MYFILES:" $MYFILES
    mkdir -p output
    for FULL_FILENAME in $MYFILES
        do 
        #loop begins (should be a list of one)
        #take the base name of the full filename (drop suffix)
        FILENAME=${FULL_FILENAME%.*}
        echo $FILENAME
        #goes into input directory and removes any csvs. Then unzip one csv into input. We will unzip and process each csv one at a time.
        pushd input
        
        #rm *.csv || echo "Failed to remove any csvs"
        find . -name "*.csv" -delete

        echo "unzipping " $FULL_FILENAME
        unzip -P $MASTERCARD_PASSWORD $FULL_FILENAME || exit 519
        
        #find the csv. There should only be one because you greped the tail.
        CSV_FILENAME=$(find . -name "*.csv")
        popd
                
        #create a new fileneame based on start and end dates.
        NEW_FILENAME=$(python create_filename.py ./input/$FULL_FILENAME)
        echo "New filename: " $NEW_FILENAME 

        python process_mastercard_main.py ./input/$CSV_FILENAME >> ./output/$NEW_FILENAME.csv
        #Write Version info
        echo "version: " $VERSION
        echo "$VERSION_$NEW_FILENAME. There are $ROWCOUNT files in this batch" >> ./output/version.txt
        
        #before you close, upload a copy to AWS
        aws s3 cp --region $AWS_DEFAULT_REGION ./output/$NEW_FILENAME.csv s3://recovery-data-partnership/mastercard_processed/$NEW_FILENAME.csv || AWS_ERROR=1

    done
    #loop ends

    #Can't so sharepoint outside proxy.
)
