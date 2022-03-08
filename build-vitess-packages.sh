#!/bin/bash

# This script builds and packages a Vitess release suitable for creating a new
# release on https://github.com/vitessio/vitess/releases.

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

# Move into the Vitess Directory
cd /home/planetscale/vitess

# shellcheck disable=SC1091
source build.env


# Pull fresh code
git pull

# Gather Version Revision Information
SHORT_REV="$(git rev-parse --short HEAD)"
if [ -n "$*" ]; then
    VERSION="$1"
else
    VERSION="$(grep -Po '(?<=const versionName = ").*(?=")' ${VTROOT}/go/vt/servenv/version.go | sed 's/-/_/')"
fi

OLD_REV=$(tail -1 ${CODESPACE_VSCODE_FOLDER}/vitess-release-roster.md | grep -Po '(?<=tag/).*(?=\))')

if [[ ${SHORT_REV} == ${OLD_REV} ]]; then
    echo "The OLD revision ${OLD_REV} and new revsision match ${SHORT_REV}."
    echo "No changes made this week closing out utility."
    exit 1
fi

RELEASE_ID="vitess-${VERSION}-${SHORT_REV}"

DESCRIPTION="A database clustering system for horizontal scaling of MySQL

Vitess is a database solution for deploying, scaling and managing large
clusters of MySQL instances. It's architected to run as effectively in a public
or private cloud architecture as it does on dedicated hardware. It combines and
extends many important MySQL features with the scalability of a NoSQL database."

# Define Paths
RELEASE_ROOT="${HOME}/releases"
RELEASE_DIR="${RELEASE_ROOT}/${RELEASE_ID}"
DOC_DIR="${RELEASE_DIR}/share/vitess/"
APPLE_BIN="/go/bin/darwin_amd64"

# Create directories to hold our files
mkdir -p ${RELEASE_DIR}/bin
mkdir -p ${DOC_DIR}
mkdir -p ${HOME}/go/bin/darwin_amd64

# File names to use for linux/apple tar files
TAR_FILE="${RELEASE_ID}.tar.gz"
APPLE_TAR_FILE="${RELEASE_ID}_darwin_amd64.tar.gz"

echo "Building Tools..."
make tools >/dev/null

echo "Building Vitess..."
make build >/dev/null

# Cross compiler has problems if vttablet file is not in place and empty
echo "" > ${HOME}/go/bin/darwin_amd64/vttablet

echo "Building Vitess for Apple amd64..."
GOOS=darwin GOARCH=amd64 make cross-build 2>/dev/null

echo "Copying files into staging directory ${RELEASE_DIR}..."
for binary in vttestserver mysqlctl mysqlctld query_analyzer topo2topo vtaclcheck vtbackup vtbench vtclient vtcombo vtctl vtctldclient vtctlclient vtctld vtexplain vtgate vttablet vtorc vtworker vtworkerclient zk zkctl zkctld; do
 cp -a "${VTROOT}/bin/$binary" "${RELEASE_DIR}/bin/"
done;
cp -a ${VTROOT}/examples ${DOC_DIR}
echo "Follow the installation instructions at: https://vitess.io/docs/get-started/local/" > "${DOC_DIR}"/examples/README.md

echo "Creating Apple Client tar file..."
tar -czf ${RELEASE_ROOT}/${APPLE_TAR_FILE} -C ${APPLE_BIN} vtctlclient vtexplain vtctl

echo "Creating linux tar file..."
tar -czf ${RELEASE_ROOT}/${TAR_FILE} -C ${RELEASE_ROOT} ${RELEASE_ID}

# For RPMs and DEBs, binaries will be in /usr/bin
# Examples will be in /usr/share/vitess/examples
PREFIX=${PREFIX:-/usr}

echo "Creating Debian Package..."
fpm \
   --force \
   --input-type dir \
   --name vitess \
   --version "${VERSION}" \
   --url "https://vitess.io/" \
   --description "${DESCRIPTION}" \
   --license "Apache License - Version 2.0, January 2004" \
   --prefix "$PREFIX" \
   -C "${RELEASE_DIR}" \
   --before-install "$VTROOT/tools/preinstall.sh" \
   --package "$(dirname "${RELEASE_DIR}")" \
   --iteration "${SHORT_REV}" \
   -t deb --deb-no-default-config-files


echo "Creating RHEL Package..."
fpm \
   --force \
   --input-type dir \
   --name vitess \
   --version "${VERSION}" \
   --url "https://vitess.io/" \
   --description "${DESCRIPTION}" \
   --license "Apache License - Version 2.0, January 2004" \
   --prefix "$PREFIX" \
   -C "${RELEASE_DIR}" \
   --before-install "$VTROOT/tools/preinstall.sh" \
   --package "$(dirname "${RELEASE_DIR}")" \
   --iteration "${SHORT_REV}" \
   -t rpm


echo "Now updating vitess-release-roster.md ...."
cd /workspaces/vitess-releases
printf "| $(date +%x) | @${GITHUB_USER} | [${SHORT_REV}](https://github.com/planetscale/vitess-releases/releases/tag/${SHORT_REV}) |" >> vitess-release-roster.md
git add vitess-release-roster.md
git commit -s -m "Updating Roster with build ${SHORT_REV}"
git push

echo ""
echo "Packages created as of $(date +"%m-%d-%y") at $(date +"%r %Z")"
echo ""
echo "Package | SHA256"
echo "------------ | -------------"
for file in $(ls ${RELEASE_ROOT} | grep ${SHORT_REV}); do
    if [[ -f ${RELEASE_ROOT}/${file} ]]; then
        echo "$file | $(sha256sum ${RELEASE_ROOT}/${file} | awk '{print $1}')";
    fi
done

echo ""
echo ""
echo "Files can be found in the ${RELEASE_ROOT} directory."
echo "Ensure your ssh port 2222 is open in codespaces."
echo "Download files with rsync"
echo ""
printf "rsync -avz -e 'ssh -p 2222' planetscale@localhost:${RELEASE_ROOT}/{"
for file in $(ls ${RELEASE_ROOT} | grep ${SHORT_REV}); do
    if [[ -f ${RELEASE_ROOT}/${file} ]]; then
        printf "${file},"
    fi
done | sed 's/,$/\} .\//'
echo ""
echo ""

