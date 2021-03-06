#!/bin/bash
source $(pwd)/bin/cli.sh
source $(pwd)/bin/axway.sh

DATE=$(date "+%Y-%m-%d")

function set_env {
  for envfile in $@
  do
    if [ -f $envfile ]
      then
        export $(cat $envfile | sed 's/#.*//g' | xargs)
      fi
  done
}
set_env .env

function urlparse {
    proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    url=$(echo $1 | sed -e s,$proto,,g)
    userpass="$(echo $url | grep @ | cut -d@ -f1)"
    BUILD_PWD=`echo $userpass | grep : | cut -d: -f2`
    BUILD_USER=`echo $userpass | grep : | cut -d: -f1`
    hostport=$(echo $url | sed -e s,$userpass@,,g | cut -d/ -f1)
    BUILD_HOST="$(echo $hostport | sed -e 's,:.*,,g')"
    BUILD_PORT="$(echo $hostport | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"
    BUILD_DB="$(echo $url | grep / | cut -d/ -f2-)"
}

function SHP_export {
  urlparse $1
  mkdir -p $4 &&
    (
      cd $4
      ogr2ogr -progress -f "ESRI Shapefile" $4.shp \
          PG:"host=$BUILD_HOST user=$BUILD_USER port=$BUILD_PORT dbname=$BUILD_DB password=$BUILD_PWD" \
          -nlt $3 $2
        rm -f $4.zip
        zip -9 $4.zip *
        ls | grep -v $4.zip | xargs rm
      )
  mv $4/$4.zip $4.zip
  rm -rf $4
}

function CSV_export {
  psql $1  -c "\COPY (
    SELECT * FROM $2
  ) TO STDOUT DELIMITER ',' CSV HEADER;" > $3.csv
}

function setup {
  mc alias set spaces $AWS_S3_ENDPOINT $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY --api S3v4
  mc alias set kinsa https://s3.amazonaws.com $KINSA_ACCESS_KEY_ID $KINSA_SECRET_ACCESS_KEY --api S3v4
  mc alias set cuebiq https://s3.amazonaws.com $CUEBIQ_ACCESS_KEY_ID $CUEBIQ_SECRET_ACCESS_KEY --api S3v4
}
register 'setup' '' 'install system dependencies' setup

function import_spatial {
  psql $RDP_DATA -c "
    DROP TABLE IF EXISTS doitt_zipcodeboundaries CASCADE;
    CREATE TABLE doitt_zipcodeboundaries (
      v text,
      ogc_fid integer,
      zipcode integer,
      bldgzip integer,
      po_name text,
      population double precision,
      area double precision,
      state character varying(2),
      county text,
      st_fips character varying(2),
      cty_fips character varying(3),
      url text,
      shape_area double precision,
      shape_len double precision,
      wkb_geometry geometry(MultiPolygon,4326)
  );
  "
  cat recipes/_data/doitt_zipcodeboundaries.csv | psql $RDP_DATA -c "\copy doitt_zipcodeboundaries from stdin DELIMITER ',' CSV HEADER;"

   psql $RDP_DATA -c "
    DROP TABLE IF EXISTS dcp_ntaboundaries CASCADE;
    CREATE TABLE dcp_ntaboundaries (
      v text,
      ogc_fid integer,
      borocode character varying(1),
      boroname text,
      countyfips character varying(3),
      ntacode character varying(4),
      ntaname text,
      shape_leng double precision,
      shape_area double precision,
      wkb_geometry geometry(MultiPolygon,4326)
    );
  "
  cat recipes/_data/dcp_ntaboundaries.csv | psql $RDP_DATA -c "\copy dcp_ntaboundaries from stdin DELIMITER ',' CSV HEADER;"

  psql $RDP_DATA -c "
  DROP TABLE IF EXISTS city_zip_boro CASCADE;
    CREATE TABLE city_zip_boro (
      zipcode text,
      city text,
      boro text
    );
  "
  cat recipes/_data/city_zip_boro.csv | psql $RDP_DATA -c "\copy city_zip_boro from stdin DELIMITER ',' CSV HEADER;"

}
register 'import' 'spatial' 'import zipcode and nta boundaries' import_spatial


function max_bg_procs {
    if [[ $# -eq 0 ]] ; then
            echo "Usage: max_bg_procs NUM_PROCS.  Will wait until the number of background (&)"
            echo "           bash processes (as determined by 'jobs -pr') falls below NUM_PROCS"
            return
    fi
    local max_number=$((0 + ${1:-0}))
    while true; do
            local current_number=$(jobs -pr | wc -l)
            if [[ $current_number -lt $max_number ]]; then
                    break
            fi
            sleep 1
    done
}


function get_last_monday {
    input_date=$(date -d "$1" +%Y-%m-%d)
    start_date=$(date -d "$input_date - 14 days")
    d=
    n=0
    until [ "$d" = "$input_date" ]
    do  
        ((n++))
        d=$(date -d "$start_date + $n days" +%Y-%m-%d)
        DOW=$(date -d "$d" +%a)
        if [ "$DOW" == "Mon" ]; then
            echo "$d"
            break
        fi
    done
}

function Upload {
  python3 ../../bin/sharepoint.py $1/$2
}

function Version {
  mkdir -p output && 
    (
        cd output 
        echo "$1,$2,$3,$(date)" > $4.txt
    )
  Upload "Shared%20Documents" "versions"
  rm -rf output
}