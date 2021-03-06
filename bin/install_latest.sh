#!/bin/bash

# Vitess Installer Script
#
# This script exists to help install a Vitess release as a tar package rather
# than as a prebuilt Docker image.

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

if [[ $OSTYPE != "linux-gnu" ]]; then
    echo "Non-linux OS detected. Exiting."
    exit 1
fi

INSTALL_DIR=${HOME}
RELEASE_REPO_URL=https://api.github.com/repos/planetscale/vitess-releases/releases/latest
LATEST_RELEASE_URL=$(curl -s ${RELEASE_REPO_URL} | grep "browser_download_url.*gz" | awk -F'"' '{print $4}' | grep -v darwin)
RELEASE_GZ_FILE=$(echo "${LATEST_RELEASE_URL}" | awk -F'/' '{print $NF}')
# shellcheck disable=SC2001
RELEASE_DIR=$(echo "${RELEASE_GZ_FILE}" | sed -e 's,\.tar.gz$,,')
EXPECTED_CHECKSUM=$(curl -s ${RELEASE_REPO_URL} | grep -oe "[0-9a-f]\{64\}" | head -n 1)

mkdir -p "${INSTALL_DIR}/downloads"
cd "${INSTALL_DIR}/downloads" || exit
echo "Downloading $RELEASE_GZ_FILE"
curl -OL "${LATEST_RELEASE_URL}"
if [[ $EXPECTED_CHECKSUM != "$(sha256sum "$RELEASE_GZ_FILE" | awk '{print $1}')" ]]; then
    echo "Checksum mismatch. Exiting."
    exit 1
fi
tar -xzf "${RELEASE_GZ_FILE}" -C "${INSTALL_DIR}"
ln -sf "${INSTALL_DIR}/${RELEASE_DIR}" "${INSTALL_DIR}/vitess"

echo "Latest release of vitess installed (${INSTALL_DIR}/vitess -> ${INSTALL_DIR}/${RELEASE_DIR})!"
echo Do the following to take it for a spin:
echo "cd ${INSTALL_DIR}/vitess"
echo cat examples/README.md
