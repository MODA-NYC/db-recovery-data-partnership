#!/bin/bash
source $(pwd)/bin/config.sh
source $(pwd)/recipes/foursquare/runner_zipcode.sh
source $(pwd)/recipes/foursquare/runner_county.sh
TYPE=$1 # zipcode/county

case $TYPE in
    zipcode)
        # updating foursquare zipcode
        foursquare_zipcode
    ;;
    county)
        # updating foursquare county
        foursquare_county
    ;;
esac