#!/bin/bash

# This script builds and packages a Vitess release suitable for creating a new
# release on https://github.com/vitessio/vitess/releases.

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

DRY_RUN=${DRY_RUN:-0}
NO_CHECK_CHANGES=${NO_CHECK_CHANGES:-0}

while [ $# -gt 0 ]; do
  arg=$1
  case $arg in
    --dry-run)
      DRY_RUN=1
      ;;
    --no-check-changes)
      NO_CHECK_CHANGES=1
      ;;
  esac
  shift
done

# Portable-ish way to get the dir where this script resides.
# https://stackoverflow.com/a/246128/20045653
VITESS_RELEASES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
VITESS_ROSTER_PATH=$VITESS_RELEASES_DIR/vitess-release-roster.md

# Move into the Vitess Directory
cd /home/planetscale/vitess

# shellcheck disable=SC1091
source build.env

# Pull fresh code
git pull

# Gather Version Revision Information
# Need to ensure deb version uses - and not _
SHORT_REV="$(git rev-parse --short HEAD)"
if [ -n "$*" ]; then
  VERSION="$($1 | sed 's/-/_/')"
  DEB_VERSION="$($1 | sed 's/_/-/')"
else
  VERSION="$(grep -Po '(?<=const versionName = ").*(?=")' ${VTROOT}/go/vt/servenv/version.go | sed 's/-/_/')"
  DEB_VERSION="$(grep -Po '(?<=const versionName = ").*(?=")' ${VTROOT}/go/vt/servenv/version.go)"
fi

OLD_REV=$(tail -1 $VITESS_ROSTER_PATH | grep -Po '(?<=tag/).*(?=\))')

# Check to see if there were changes; exit if there are none
if [[ ${SHORT_REV} == ${OLD_REV} ]]; then
  if [ ${NO_CHECK_CHANGES} -eq 1 ]; then
    echo "No changes made this week, but proceeding anyway."
  else
    echo "The OLD revision ${OLD_REV} and new revision match ${SHORT_REV}."
    echo "No changes made this week closing out utility."
    exit 1
  fi
fi

RELEASE_ID="vitess-${VERSION}-${SHORT_REV}"

DESCRIPTION="A database clustering system for horizontal scaling of MySQL

Vitess is a database solution for deploying, scaling and managing large
clusters of MySQL instances. It's architected to run as effectively in a public
or private cloud architecture as it does on dedicated hardware. It combines and
extends many important MySQL features with the scalability of a NoSQL database."

# Authentication
GH_TOKEN="${GH_TOKEN:-""}"
GITHUB_ACTOR="${GITHUB_ACTOR:-""}"
GITHUB_TOKEN="${GITHUB_TOKEN:-""}"
GITHUB_USER="${GITHUB_USER:-""}"

if [ -z "$GH_TOKEN" ] && [ -z "$GITHUB_TOKEN" ]; then
  echo "Neither \$GH_TOKEN nor \$GITHUB_TOKEN are set."
  exit 1
fi

# Define Paths
RELEASE_ROOT="${HOME}/releases"
RELEASE_DIR="${RELEASE_ROOT}/${RELEASE_ID}"
DOC_DIR="${RELEASE_DIR}/share/vitess/"
APPLE_BIN="${VTROOT}/bin/darwin_amd64"

# Create directories to hold our files
mkdir -p ${RELEASE_DIR}/bin
mkdir -p ${DOC_DIR}
mkdir -p ${APPLE_BIN}

# File names to use for linux/apple tar files
TAR_FILE="${RELEASE_ID}.tar.gz"
APPLE_TAR_FILE="${RELEASE_ID}_darwin_amd64.tar.gz"

echo "Building Tools..."
make tools >/dev/null

echo "Building Vitess..."
make build >/dev/null

echo "Copying files into staging directory ${RELEASE_DIR}..."
for binary in vttestserver mysqlctl mysqlctld query_analyzer topo2topo vtaclcheck vtbackup vtbench vtclient vtcombo vtctl vtctldclient vtctlclient vtctld vtexplain vtgate vttablet vtorc zk zkctl zkctld; do
  cp -a "${VTROOT}/bin/$binary" "${RELEASE_DIR}/bin/"
done;

echo "Building Vitess for Apple amd64..."
GOOS=darwin GOARCH=amd64 make cross-build >/dev/null

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
  --version "${DEB_VERSION}" \
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


if [ $DRY_RUN -eq 0 ]; then
  echo "Now updating vitess-release-roster.md ...."
  user="$GITHUB_USER"
  if [ -z "$user" ]; then
    user="$GITHUB_ACTOR"
  fi
  cd $VITESS_RELEASES_DIR
  echo "| $(date +%x) | @${user} | [${SHORT_REV}](https://github.com/planetscale/vitess-releases/releases/tag/${SHORT_REV}) |" >> $VITESS_ROSTER_PATH

  echo "Adding, committing, pushing updated roster..."
  git add vitess-release-roster.md
  git commit -s -m "Updating Roster with build ${SHORT_REV}"
  git push
else
  echo "[dry-run] Skipping roster update."
fi


echo "Generating release notes ...."
notes="/tmp/release-notes.txt"
cat > ${notes} << EOF

Packages created as of $(date +"%m-%d-%y") at $(date +"%r %Z")

Package | SHA256
------------ | -------------
EOF

# Generate list of files ${RELEASE_FILES} and sha256 values for release notes
RELEASE_FILES=""
for file in $(ls ${RELEASE_ROOT} | grep ${SHORT_REV}); do
   if [[ -f ${RELEASE_ROOT}/${file} ]]; then
     RELEASE_FILES="${RELEASE_FILES} ${RELEASE_ROOT}/${file}";
     echo "${file} | $(sha256sum ${RELEASE_ROOT}/${file} | cut -d ' ' -f 1)" >> ${notes};
   fi
done

# Display notes for troubleshooting purposes

cat ${notes}

echo;echo

if [ $DRY_RUN -eq 0 ]; then
  echo "Creating GitHub Release..."
  gh release create -F /tmp/release-notes.txt -t "Vitess Release ${VERSION}-${SHORT_REV}" ${SHORT_REV}
  for file in ${RELEASE_FILES}; do
    attempts=0
    while [ $attempts -lt 3 ]; do
      echo "Attaching file $file to release, attempt #${attempts}..."
      if gh release upload --clobber "${SHORT_REV}" "$file"; then
        echo "Successfully attached file $file to GitHub Release."
        break
      fi
      attempts=$(expr $attempts + 1)
    done
  done
  echo "Successfully created GitHub Release."
else
  echo "[dry-run] Skipping GitHub Release and uploading files."
fi

echo "All work complete exiting now..."

exit 0
