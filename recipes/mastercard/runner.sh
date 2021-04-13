#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


( 
    cd $BASEDIR
    mkdir -p input
    mkdir -p output
    
    #pull the directory
    
    #extract
    unzip -d /input -P $MASTERCARD_PASSWORD $(find $BASEDIR -name "*.zip" | head -1)
    
    #modify csv in python
    (ulimit -t 300
    bash -x 
    python build.py)

    #clean-up
    rm -f -r input output

    

)