#!/bin/bash
source $(pwd)/bin/config.sh

BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE


AWS_DEFAULT_REGION=us-east-1

(   
    cd $BASEDIR
    python sharepoint_test.py
    )
