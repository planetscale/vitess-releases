#!/bin/bash

PREFIX=${PREFIX:-/usr}

inputs_file="/tmp/inputs"
cat <<EOF > "${inputs_file}"
bin/mysqlctld=${PREFIX}/bin/mysqlctld
bin/vtbackup=${PREFIX}/bin/vtbackup
bin/vtctl=${PREFIX}/bin/vtctl
bin/vtctlclient=${PREFIX}/bin/vtctlclient
bin/vtctld=${PREFIX}/bin/vtctld
bin/vtgate=${PREFIX}/bin/vtgate
bin/vttablet=${PREFIX}/bin/vttablet
bin/vtworker=${PREFIX}/bin/vtworker
config/=/etc/vitess
web/vtctld2=${PREFIX}/lib/vitess/web
web/vtctld=${PREFIX}/lib/vitess/web
examples/local/=${PREFIX}/share/vitess/examples
EOF

description='A database clustering system for horizontal scaling of MySQL

Vitess is a database solution for deploying, scaling and managing large
clusters of MySQL instances. It’s architected to run as effectively in a public
or private cloud architecture as it does on dedicated hardware. It combines and
extends many important MySQL features with the scalability of a NoSQL database.'

exec /usr/local/bin/fpm \
    --force \
    --input-type dir \
    --name vitess \
    --version "3.0.0" \
    --url "https://vitess.io/" \
    --description "${description}" \
    --license "Apache License - Version 2.0, January 2004" \
    --inputs "${inputs_file}" \
    --config-files "/etc/vitess" \
    --directories "${PREFIX}/lib/vitess" \
    --before-install "${BASH_SOURCE%/*}/preinstall.sh" \
    "${@}"
