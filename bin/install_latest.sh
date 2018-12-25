#!/bin/bash

INSTALL_DIR=${HOME}
RELEASE_REPO_URL=https://api.github.com/repos/planetscale/vitess-releases/releases/latest
LATEST_RELEASE_URL=$(curl -s ${RELEASE_REPO_URL} | grep "browser_download_url.*gz" | awk -F'"' '{print $4}')
RELEASE_GZ_FILE=$(echo ${LATEST_RELEASE_URL} | awk -F'/' '{print $NF}')
RELEASE_DIR=$(echo ${RELEASE_GZ_FILE} | sed -e 's,\.tar.gz$,,')
mkdir -p ${INSTALL_DIR}/downloads
cd ${INSTALL_DIR}/downloads
curl -OL ${LATEST_RELEASE_URL}
tar -xzf ${RELEASE_GZ_FILE} -C ${INSTALL_DIR}
ln -sf ${INSTALL_DIR}/${RELEASE_DIR} ${INSTALL_DIR}/vitess
echo Latest release of vitess installed \(${INSTALL_DIR}/vitess -\> ${INSTALL_DIR}/${RELEASE_DIR}\)!
echo Do the following to take it for a spin:
echo cd ${INSTALL_DIR}/vitess
echo cat README.md
