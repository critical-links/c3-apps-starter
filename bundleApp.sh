#!/bin/bash

# check arguments
if [ -z $1 ]
then
	echo "This script require a valid package name ex '${0} wordpress'"
	exit 1
fi
# check if package dir exists
if [ ! -d "${1}" ]; then
  # Take action if $DIR exists. #
  echo "can't find package name directory '${1}'..."
  exit 1
fi

COMMON_PATH=@common
set -a
. ${COMMON_PATH}/common.env
set +a
# load bundle helper variables
set -a
. ${1}/bundle.env
set +a

# cli args
PACKAGE_NAME=${1}
# init variables
DEPLOY_PATH=@deploy-versions
COMMON_PATH=@common
PACKAGE_DIR=package
PACKAGE_PATH=${PACKAGE_NAME}
# base filename/without paths
PACKAGE_BASE_FILEPATH=${DEPLOY_PATH}/${PACKAGE_NAME}
PACKAGE_VERSION=$(cat ${PACKAGE_PATH}/VERSION)
PACKAGE_BASE_FILENAME=${PACKAGE_NAME}_${PACKAGE_VERSION}
PACKAGE_BUNDLE_FILENAME=${PACKAGE_BASE_FILENAME}.${PACKAGE_BASE_FILENAME_EXTENSION}
PACKAGE_BUNDLE_PROPS_FILENAME="${PACKAGE_PATH}/${C3_PACKAGE_DATA_FILENAME}"
PACKAGE_MD5_FILENAME=${PACKAGE_BASE_FILENAME}.md5

# common files
for filename in ${COMMON_PATH}/*.*; do
  basename="$(basename -- ${filename})"
  if [ "${basename}" == "${SCRIPT_POST_INSTALL_FILE_NAME}" ]; then
    if [ ! -f "${PACKAGE_NAME}/${basename}" ]; then
      # copy custom user files only if file doesn't exists already
      printf "#!/bin/bash\\n\\n"> "${PACKAGE_NAME}/${basename}"
      cat "${filename}" >> "${PACKAGE_NAME}/${basename}"
    fi
  else
    # always copy/update/overrite file if not custom user file
    printf "#!/bin/bash\\n\\n"> "${PACKAGE_NAME}/${basename}"
    printf "####################################################################################################################################\\n" >> "${PACKAGE_NAME}/${basename}"
    printf "# DON'T EDIT THIS FILE, it will be replaced with @common file on bundleApp.sh                                                      #\\n" >> "${PACKAGE_NAME}/${basename}"
    printf "####################################################################################################################################\\n\\n" >> "${PACKAGE_NAME}/${basename}"
    cat "${filename}" >> "${PACKAGE_NAME}/${basename}"
  fi
done
# don't forget to change permissions, else we get `-bash: ./install.sh: Permission denied` on c3-cloud-client
find . -name '*.sh' -exec chmod a+x {} +

if [ ! -d "${1}" ]; then
  # Take action if $DIR exists. #
  echo "can't find package name directory '${1}'..."
  exit 1
fi

# default package extract files, added to data.json has array
for file in "${C3_PACKAGE_EXTRACT_FILES[@]}"
do
	PACKAGE_EXTRACT_FILES="${PACKAGE_EXTRACT_FILES}\"${file}\","
done
# TODO remove
# ports
# for port in "${APP_EXPOSED_PORTS[@]}"
# do
# 	EXPOSED_PORTS="${EXPOSED_PORTS}\"${port}\","
# done
# remove last comma
PACKAGE_EXTRACT_FILES=${PACKAGE_EXTRACT_FILES::-1}
# TODO remove
# EXPOSED_PORTS=${PACKAGE_PORTS::-1}
# save it initial state
cat > ${PACKAGE_BUNDLE_PROPS_FILENAME} <<- EOM
{
  "appName": "${PACKAGE_NAME}",
  "domain": "${PACKAGE_NAME}.${C3_DOMAIN}",
  "version": "${PACKAGE_VERSION}",
  "instructions": "${APP_INSTRUCTIONS}",  
  "state": "${SERVICE_STATE_INSTALLING}",
  "bundleFilename": "${PACKAGE_BUNDLE_FILENAME}",
  "extractFiles": [${PACKAGE_EXTRACT_FILES}],
  "exposedPorts": [${APP_EXPOSED_PORTS}]
}
EOM

# pack file
mkdir -p ${PACKAGE_BASE_FILEPATH} -p
cd ${PACKAGE_PATH}
tar -zcf ../${PACKAGE_BASE_FILEPATH}/${PACKAGE_BUNDLE_FILENAME} * --owner=0 --group=0

echo "done with ${PACKAGE_NAME} bundle."
