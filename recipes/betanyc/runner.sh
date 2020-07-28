#!/bin/bash
source $(pwd)/bin/config.sh
BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
VERSION=$DATE

(
    cd $BASEDIR
    mkdir -p input
    mkdir -p output
    
    docker run --rm\
        -v $(pwd)/../:/recipes\
        -w /recipes/$NAME\
        --user $UID\
        nycplanning/docker-geosupport:latest python3 build.py |
    psql $RDP_DATA -v NAME=$NAME -v VERSION=$VERSION -f create.sql

)