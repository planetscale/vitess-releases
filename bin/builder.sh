#!/usr/bin/env bash

# This script builds and packages a Vitess release suitable for creating a new
# release on https://github.com/vitessio/vitess/releases.

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

sudo apt-get -y install make automake \
    libtool libssl-dev g++ git \
    pkg-config bison curl unzip zip \
    build-essential ruby-dev rubygems rpm

sudo gem install --no-ri --no-rdoc fpm

INSTALL_GO=0
if [ -f /usr/local/go/bin/go ]; then
    if ! /usr/local/go/bin/go version | grep -q go1.13.4; then
	    INSTALL_GO=1
    fi
else
    INSTALL_GO=1
fi

if [ $INSTALL_GO -eq 1 ] ; then
    mkdir -p "$HOME/downloads"
    cd "$HOME/downloads"
    curl -OL https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.13.4.linux-amd64.tar.gz
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
#git checkout remotes/planetscale/$1
#git pull planetscale $1
git checkout master
git pull 
./tools/make-release-packages.sh
