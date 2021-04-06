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
        ./rdp setup || echo './rdp setup failed'
        mkdir -p ~/.ssh || echo 'mkdir failed'
        mc cp spaces/recovery-data-partnership/utils/id_rsa ~/.ssh/id_rsa_axway || echo 'mc cp failed'
        chmod 600 ~/.ssh/id_rsa_axway || echo 'chmod failed'
        bash /_w/recipes/$1/runner.sh $2 || echo 'runer.sh failed'
        "
}
register 'run' 'local' '{ recipe name }' local_run

function versions {
    python3 $(pwd)/bin/versions.py
}
register 'run' 'versions' '' versions

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
    opportunity_insights)
        case $2 in
            weekly | daily)
                curl --location --request POST 'https://api.github.com/repos/MODA-NYC/db-recovery-data-partnership/dispatches?Accept=application/vnd.github.v3+json&Content-Type=application/json' \
                --header "Authorization: Bearer $GITHUB_TOKEN" \
                --header 'Content-Type: text/plain' \
                --data-raw "{\"event_type\" : \"opportunity_insights_$2\"}"
            ;;
            *) 
                echo "$2 is not recognized! please enter weekly or daily"
            ;;
            esac
    ;;
    street_easy | kinsa | betanyc | upsolve | linkedin | oats | usl | ioby | met )
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
