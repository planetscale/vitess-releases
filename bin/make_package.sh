#!/bin/bash

description='A database clustering system for horizontal scaling of MySQL

Vitess is a database solution for deploying, scaling and managing large
clusters of MySQL instances. It’s architected to run as effectively in a public
or private cloud architecture as it does on dedicated hardware. It combines and
extends many important MySQL features with the scalability of a NoSQL database.'

exec /usr/local/bin/fpm \
    --force \
    --input-type dir \
    --name vitess \
    --version "4.0.0" \
    --url "https://vitess.io/" \
    --description "${description}" \
    --license "Apache License - Version 2.0, January 2004" \
    --prefix "/vt" \
    --directories "/vt" \
    --before-install "${BASH_SOURCE%/*}/preinstall.sh" \
    "${@}"
