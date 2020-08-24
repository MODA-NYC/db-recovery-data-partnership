#!/bin/bash
source $(pwd)/bin/config.sh
source $(pwd)/recipes/foursquare/runner_datacube.sh
source $(pwd)/recipes/foursquare/runner_default.sh

BASEDIR=$(dirname $0)
NAME=$(basename $BASEDIR)
TYPE=$1 # datacube/*

case $TYPE in
    datacube)
        # updating foursquare datacube
        foursquare_datacube
    ;;
    *)
        # Default pulling county level foursquare data
        foursquare_default
    ;;
esac