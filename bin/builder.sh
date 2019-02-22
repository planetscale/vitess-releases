#!/bin/bash

# This script builds and packages a Vitess release suitable for creating a new
# release on https://github.com/vitessio/vitess/releases.

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

sudo apt-get -y install make automake \
    libtool libssl-dev g++ git \
    pkg-config bison curl unzip zip

DIR=$PWD/$(dirname "$0")

INSTALL_GO=0
if [ -f /usr/local/go/bin/go ]; then
    if ! /usr/local/go/bin/go version | grep -q go1.11.4; then
	    INSTALL_GO=1
    fi
else
    INSTALL_GO=1
fi

if [ $INSTALL_GO -eq 1 ] ; then
    mkdir -p "$HOME/downloads"
    cd "$HOME/downloads"
    curl -OL https://dl.google.com/go/go1.11.4.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.11.4.linux-amd64.tar.gz
fi

mkdir -p "$HOME/go"
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export PATH=${PATH}:${GOBIN}

cd "$GOPATH"
if [ ! -d src/vitess.io/vitess ]; then
    echo Cloning Vitess source
    git clone https://github.com/vitessio/vitess.git src/vitess.io/vitess
fi

cd src/vitess.io/vitess
git pull

BUILD_TESTS=0 ./bootstrap.sh
make build

RELEASE_ID=vitess-release-$(git rev-parse --short HEAD)

mkdir -p ~/releases
RELEASE_DIR=${HOME}/releases/${RELEASE_ID}

for d in bin lib dist config pkg vthook; do
    mkdir -p "${RELEASE_DIR}/$d"
    echo cp -Lrpf "$HOME/go/$d/." "${RELEASE_DIR}/$d"
    cp -Lrpf "$HOME/go/$d/." "${RELEASE_DIR}/$d"
done

for d in chromedriver grpc MYSQL_FLAVOR py-mock-1.0.1 selenium vt-protoc-3.6.1; do
    rm -rf "${RELEASE_DIR}/dist/$d"
done

mkdir -p "${RELEASE_DIR}/web"
cp -rpf "$HOME/go/src/vitess.io/vitess/web/." "${RELEASE_DIR}/web"

mkdir -p "${RELEASE_DIR}/examples"
cp -rpf "$HOME/go/src/vitess.io/vitess/examples/." "${RELEASE_DIR}/examples"

cp "${DIR}/release_README.md" "${RELEASE_DIR}/README.md"

cd "${RELEASE_DIR}/.."
tar -czf "${RELEASE_ID}.tar.gz" "${RELEASE_ID}"
