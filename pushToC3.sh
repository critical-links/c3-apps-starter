#!/bin/bash

[[ EUID -ne 0 ]] && echo "This script must be run as root." && exit 1

# check arguments
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]
then
	echo "This script require a valid c3app name, version and syncthing folderId ex '${0} wordpress 1.0.0 0008100'"
	exit 1
fi
# check if package dir exists
if [ ! -d "${1}" ]; then
  # Take action if $DIR exists. #
  echo "can't find package name directory '${1}'..."
  exit 1
fi

# used only to copy files to c3

# user variables
C3_ADDRESS="c3@c3edu.online"
C3_PASS="root"
SYNCTHING_APP_DIR="${3}"
# script variables
APP_NAME="${1}"
APP_VERSION="${2}"
C3_BASE_CMD="sshpass -p${C3_PASS} ssh -tt ${C3_ADDRESS}"
PACKAGE_BASE_FILENAME_EXTENSION="c3app"
TEMP_PATH="/tmp/c3apps"
APP_FILEPATH="@deploy-versions/${APP_NAME}/${APP_NAME}_${APP_VERSION}.${PACKAGE_BASE_FILENAME_EXTENSION}"
# folder /home works in 4.x and 5.x, in 5.x we use data folder but we have a symbolic link /home/syncthing/data > /data/syncthing/data
SYNCTHING_APP_PATH="/home/syncthing/data/${SYNCTHING_APP_DIR}"
SYNCTHING_INSTALL_SCRIPT="syncthingInstall.sh"
SYNCTHING_UNINSTALL_SCRIPT="syncthingUninstall.sh"
SCP_FLAGS="-q -o LogLevel=QUIET"

# always bundle, re-bundle app
./bundleApp.sh ${APP_NAME}

# check if app version exists
if [ ! -f "${APP_FILEPATH}" ]; then
  echo "can't find app in file path '${APP_FILEPATH}', please check file path"
  exit 1
fi

# always delete TEMP_PATH to prevent /tmp/c3apps file
CMD="[ -d "${TEMP_PATH}" ]; rm -r ${TEMP_PATH}"
${C3_BASE_CMD} 'echo '${C3_PASS}' | sudo -S -s /bin/bash -c "'${CMD}'"'
# mkdir and change onwner
CMD="mkdir '${TEMP_PATH}' -p; chown c3.c3 '${TEMP_PATH}'"
${C3_BASE_CMD} 'echo '${C3_PASS}' | sudo -S -s /bin/bash -c "'${CMD}'"'
# copy preInstall.sh script
scp ${SCP_FLAGS} ${SYNCTHING_INSTALL_SCRIPT} ${C3_ADDRESS}:${TEMP_PATH}
scp ${SCP_FLAGS} ${SYNCTHING_UNINSTALL_SCRIPT} ${C3_ADDRESS}:${TEMP_PATH}
# chown of SYNCTHING_INSTALL_SCRIPT
CMD="chmod a+x '${TEMP_PATH}/${SYNCTHING_INSTALL_SCRIPT}'"
${C3_BASE_CMD} 'echo '${C3_PASS}' | sudo -S -s /bin/bash -c "'${CMD}'"'
CMD="chmod a+x '${TEMP_PATH}/${SYNCTHING_UNINSTALL_SCRIPT}'"
${C3_BASE_CMD} 'echo '${C3_PASS}' | sudo -S -s /bin/bash -c "'${CMD}'"'

# copy package app file
CMD="mkdir '${SYNCTHING_APP_PATH}' -p; chown c3.c3 '${SYNCTHING_APP_PATH}'"
${C3_BASE_CMD} 'echo '${C3_PASS}' | sudo -S -s /bin/bash -c "'${CMD}'"'
scp ${SCP_FLAGS} ${APP_FILEPATH} ${C3_ADDRESS}:${SYNCTHING_APP_PATH}

# TODO: this install app, but is better to output commands and launch manually
# run syncthingInstall.sh
# CMD="cd ${TEMP_PATH}; ./${SYNCTHING_INSTALL_SCRIPT} ${APP_NAME} ${SYNCTHING_APP_DIR}"
# ${C3_BASE_CMD} 'echo '${C3_PASS}' | sudo -S -s /bin/bash -c "'${CMD}'"'
printf "\ndone, now to install and uninstall app, launch bellow scripts in path ${TEMP_PATH}\n\n"

printf "  # 1. connect to c3 via ssh\n  ssh ${C3_ADDRESS}\n\n"
printf "  # 2. enter path\n  cd ${TEMP_PATH}\n\n"
printf "  # 3. install c3app\n  sudo ./syncthingInstall.sh ${APP_NAME} ${SYNCTHING_APP_DIR}\n\n"
printf "  # 4. uninstall c3app\n  sudo ./syncthingUninstall.sh ${SYNCTHING_APP_DIR}\n\n"

unset C3_PASS
exit 0
