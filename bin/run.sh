# #!/bin/bash
source $(pwd)/bin/config.sh

function run {
    bash $(pwd)/recipes/$1/runner.sh $2
}
register 'run' 'recipe' '{ recipe name }' run

function local_run {
    docker pull nycplanning/rdp:latest && docker run --rm\
        -v $(pwd)/:/_w\
        -w /_w\
        nycplanning/rdp:latest bash -c "
        ./rdp setup
        mkdir -p ~/.ssh
        mc cp spaces/recovery-data-partnership/utils/id_rsa ~/.ssh/id_rsa_axway
        chmod 600 ~/.ssh/id_rsa_axway
        bash /_w/recipes/$1/runner.sh $2
        "
}
register 'run' 'local' '{ recipe name }' local_run

function cloud_run {
case $1 in
    cuebiq)
        case $2 in
            mobility | weekly | daily | travelers | relocation)
                curl --location --request POST 'https://api.github.com/repos/MODA-NYC/db-recovery-data-partnership/dispatches?Accept=application/vnd.github.v3+json&Content-Type=application/json' \
                --header "Authorization: Bearer $GITHUB_TOKEN" \
                --header 'Content-Type: text/plain' \
                --data-raw "{\"event_type\" : \"cuebiq_$2\"}"
            ;;
            *) 
                echo "$2 is not recognized! please enter weekly, cityhall or daily"
            ;;
            esac
    ;;
    foursquare)
        case $2 in
            county | zipcode)
                curl --location --request POST 'https://api.github.com/repos/MODA-NYC/db-recovery-data-partnership/dispatches?Accept=application/vnd.github.v3+json&Content-Type=application/json' \
                --header "Authorization: Bearer $GITHUB_TOKEN" \
                --header 'Content-Type: text/plain' \
                --data-raw "{\"event_type\" : \"foursquare_$2\"}"
            ;;
            *) 
                echo "$2 is not recognized! please enter weekly, cityhall or daily"
            ;;
            esac
    ;;
    street_easy | kinsa | betanyc | upsolve | linkedin | oats | usl | ioby )
        curl --location --request POST 'https://api.github.com/repos/MODA-NYC/db-recovery-data-partnership/dispatches?Accept=application/vnd.github.v3+json&Content-Type=application/json' \
            --header "Authorization: Bearer $GITHUB_TOKEN" \
            --header 'Content-Type: text/plain' \
            --data-raw "{\"event_type\" : \"$1\"}"
    ;;
    *)
    echo "$1 is not recognized as a recipe"
    ;;
esac
}
register 'run' 'cloud' '{ recipe name }' cloud_run
