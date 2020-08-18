# #!/bin/bash

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