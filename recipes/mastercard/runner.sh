#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


(   
    #find the filename
   
    cd $BASEDIR
    mkdir -p input
    mkdir -p output

    
    #pull the directory

    #extract
    unzip -d /input -P $MASTERCARD_PASSWORD $(find $BASEDIR -name "*.zip" |
    head -1 ) 

    #find the filename
    KEY=$(ls /input)
    FILENAME=$(basename $KEY)
    echo $FILENAME
    #send csv to PSQL
    cat /input/$FILENAME | psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create_mastercard.sql
    #clean up
    #rm -rf input
    (
        cd output
        psql $RDP_DATA -c "\COPY(
            SELECT * FROM $NAME.\"$VERSION\"
            ) TO stdout DELIMITER ',' CSV HEADER;" > mastercard.csv
        
        #Write Version info
        echo "$VERSION" > version.txt
    )
    #Upload mastercard/$NAME $VERSION
    



) 
