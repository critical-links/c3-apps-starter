#!/bin/bash

# this scrips must run in c3
# use example: 'sudo ./syncthingUninstall.sh 3456afe'

export C3_PACKAGE_BASE_DATA_PATH="/var/lib/c3apps"
export C3_PACKAGE_BASE_BUNDLE_PATH="/home/syncthing/data"

# check arguments
if [ -z $1 ]
then
	echo "This script require a valid syncthing data dir ex '${0} 3456afe'"
	exit 1
fi

SYNCTHING_APP_DIR=${1}
PACKAGE_BUNDLE_PATH="${C3_PACKAGE_BASE_BUNDLE_PATH}/${SYNCTHING_APP_DIR}"
C3_PACKAGE_DATA_PATH="${C3_PACKAGE_BASE_DATA_PATH}/${SYNCTHING_APP_DIR}"

# check if syncthing data dir exists
if [ ! -d "${PACKAGE_BUNDLE_PATH}" ]; then
  echo "can't find syncthing data directory '${PACKAGE_BUNDLE_PATH}'..."
  exit 1
fi
# check if C3_PACKAGE_DATA_PATH dir exists
if [ ! -d "${C3_PACKAGE_DATA_PATH}" ]; then
  mkdir -p ${C3_PACKAGE_DATA_PATH}
fi

# call package uninstall script
PWD=$(pwd)
cd ${C3_PACKAGE_DATA_PATH}
if [ -f "uninstall.sh" ]; then
  ./uninstall.sh ${SYNCTHING_APP_DIR}
else
  echo "seems that c3app was already uninstalled, miss file uninstall.sh in package path ${C3_PACKAGE_DATA_PATH}"
fi
