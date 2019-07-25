#!/bin/bash

PREFIX=${PREFIX:-/usr}

inputs_file="/tmp/inputs"
cat <<EOF > "${inputs_file}"
${PACKAGE_ROOT}/bin/mysqlctld=${PREFIX}/bin/mysqlctld
${PACKAGE_ROOT}/bin/vtbackup=${PREFIX}/bin/vtbackup
${PACKAGE_ROOT}/bin/vtctl=${PREFIX}/bin/vtctl
${PACKAGE_ROOT}/bin/vtctlclient=${PREFIX}/bin/vtctlclient
${PACKAGE_ROOT}/bin/vtctld=${PREFIX}/bin/vtctld
${PACKAGE_ROOT}/bin/vtgate=${PREFIX}/bin/vtgate
${PACKAGE_ROOT}/bin/vttablet=${PREFIX}/bin/vttablet
${PACKAGE_ROOT}/bin/vtworker=${PREFIX}/bin/vtworker
${PACKAGE_ROOT}/src/vitess.io/vitess/config/=/etc/vitess
${PACKAGE_ROOT}/src/vitess.io/vitess/web/vtctld2/app=${PREFIX}/lib/vitess/web/vtcld2
${PACKAGE_ROOT}/src/vitess.io/vitess/web/vtctld=${PREFIX}/lib/vitess/web
${PACKAGE_ROOT}/src/vitess.io/vitess/examples/local/=${PREFIX}/share/vitess/examples
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
    --iteration "${ITERATION}" \
    --url "https://vitess.io/" \
    --description "${description}" \
    --license "Apache License - Version 2.0, January 2004" \
    --inputs "${inputs_file}" \
    --config-files "/etc/vitess" \
    --directories "${PREFIX}/lib/vitess" \
    --before-install "${BASH_SOURCE%/*}/preinstall.sh" \
    "${@}"
