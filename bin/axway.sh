#!/bin/bash
source $(pwd)/bin/cli.sh

function axway_ls {
    sftp -q -i ~/.ssh/id_rsa_axway \
    -o HostKeyAlgorithms=+ssh-dss \
    -o KexAlgorithms=diffie-hellman-group14-sha1 \
    -o StrictHostKeyChecking=no \
    $AXWAY_USER@$AXWAY_HOST << EOF
    ls $@
EOF
}
register 'axway' 'ls' 'listing directory' axway_ls


function axway_cmd {
    sftp -q -i ~/.ssh/id_rsa_axway \
    -o HostKeyAlgorithms=+ssh-dss \
    -o KexAlgorithms=diffie-hellman-group14-sha1 \
    -o StrictHostKeyChecking=no \
    $AXWAY_USER@$AXWAY_HOST << EOF
    $@
EOF
}
register 'axway' 'cmd' 'any commands e.g. ls, du' axway_cmd