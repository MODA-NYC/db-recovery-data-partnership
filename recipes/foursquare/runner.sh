#!/bin/bash
source $(pwd)/bin/config.sh
source $(pwd)/recipes/foursquare/runner_datacube.sh
source $(pwd)/recipes/foursquare/runner_county.sh
TYPE=$1 # datacube/*

case $TYPE in
    datacube)
        # updating foursquare datacube
        foursquare_datacube
    ;;
    *)
        # Default pulling county level foursquare data
        foursquare_county
    ;;
esac