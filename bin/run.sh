# #!/bin/bash

function run {
    bash $(pwd)/recipes/$1/runner.sh
}
register 'run' 'recipe' '{ recipe name }' run

function local_run {
    docker run --rm\
        -v $(pwd)/:/_w\
        -w /_w\
        nycplanning/rdp:latest bash -c "
        ./rdp setup
        bash /_w/recipes/$1/runner.sh
        "
}
register 'run' 'local' '{ recipe name }' local_run