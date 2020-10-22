#!/bin/bash
source $(pwd)/bin/config.sh
source $(pwd)/recipes/cuebiq/runner_daily.sh
source $(pwd)/recipes/cuebiq/runner_weekly.sh
source $(pwd)/recipes/cuebiq/runner_mobility.sh
source $(pwd)/recipes/cuebiq/runner_travelers.sh
source $(pwd)/recipes/cuebiq/runner_homeswitcher.sh

BASEDIR=$(dirname $0)
VERSION=$DATE
AWS_ACCESS_KEY_ID=$CUEBIQ_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$CUEBIQ_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=us-east-1
TYPE=$1 #mobility/weekly/daily/travelers
sectors=('automotive' 'dining' 'healthcare' 'lifestyle' 'malls' 'retail' 'telco' 'transportation')

(
  cd $BASEDIR
  mkdir -p output
  mkdir -p input
)

case $TYPE in

    mobility)
        ( cuebiq_mobility ) ;;

    weekly)
        ( cuebiq_weekly ) ;;

    daily)
        ( cuebiq_daily ) ;;

    travelers)
        ( cuebiq_travelers ) ;;
    homeswitcher)
        ( cuebiq_homeswitcher ) ;;

    *)
        echo -n "
        please specify mobility, weekly, daily, homeswitcher, or travelers
        "
    ;;
esac