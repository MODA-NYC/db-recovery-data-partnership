#!/bin/bash
source $(pwd)/bin/cli.sh

#Steve added for error catching
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
#set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
#set -o errexit   ## set -e : exit the script if any statement returns a non-false return value

function axway_ls {
    #chmod 700 ~/.ssh/id_rsa_axway
    sftp -i ~/.ssh/id_rsa_axway \
    -o StrictHostKeyChecking=no \
    $AXWAY_USER@$AXWAY_HOST << EOF
    ls $@ 
EOF
}
register 'axway' 'ls' 'listing directory' axway_ls


function axway_cmd {
    sftp -i ~/.ssh/id_rsa_axway \
    -o StrictHostKeyChecking=no \
    $AXWAY_USER@$AXWAY_HOST << EOF
    $@
EOF
}
register 'axway' 'cmd' 'any commands e.g. ls, du' axway_cmd