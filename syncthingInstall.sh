#!/bin/bash

# this scrips must run in c3, that's the reason to have redeclared used variables here
# use example: './pushToC3.sh moodle 1.0.2 3456afe && sudo ./syncthingInstall.sh moodle 3456afe'

export C3_PACKAGE_BASE_DATA_PATH="/var/lib/c3apps"
export C3_PACKAGE_BASE_BUNDLE_PATH="/home/syncthing/data"
export PACKAGE_BASE_FILENAME_EXTENSION="c3app"
# this must match common.env
export C3_PACKAGE_EXTRACT_FILES=( "VERSION" "enable.sh" "disable.sh" "install.sh" "uninstall.sh" "install_pre.sh" "install_post.sh" "uninstall_pre.sh" "uninstall_post.sh" "app.env" "common.env" "data.json")

# check arguments
if [ -z $1 ] || [ -z $2 ]
then
	echo "This script require a valid package name and syncthing data dir ex '${0} wordpress 3456afe'"
	exit 1
fi

APP_NAME=${1}
SYNCTHING_APP_DIR=${2}
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

# get package filepath
PACKAGE_BUNDLE_FILEPATH=$(ls ${PACKAGE_BUNDLE_PATH}/*.${PACKAGE_BASE_FILENAME_EXTENSION})

# extract data files/ package root files
for file in "${C3_PACKAGE_EXTRACT_FILES[@]}"
do
	echo "  extracting ${file} from ${PACKAGE_BUNDLE_FILEPATH} to ${C3_PACKAGE_DATA_PATH}"
	tar --overwrite --wildcards --exclude='*/*' -xzf ${PACKAGE_BUNDLE_FILEPATH} -C ${C3_PACKAGE_DATA_PATH} ${file}
done

# call package install script
PWD=$(pwd)
cd ${C3_PACKAGE_DATA_PATH}
echo ${C3_PACKAGE_DATA_PATH}
./install.sh ${SYNCTHING_APP_DIR}
cd ${PWD}