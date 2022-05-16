#!/bin/bash

# used only to copy files to c3

APP_NAME="evergreen"
APP_VERSION="1.0.0"
SYNCTHING_APP_DIR="2e40112"
C3_IP=c3@192.168.1.120
C3_PASS=root
C3_BASE_CMD="sshpass -p${C3_PASS} ssh -tt ${C3_IP}"
PACKAGE_BASE_FILENAME_EXTENSION="c3app"
TEMP_PATH="/tmp/c3apps"
APP_FILEPATH="@deploy-versions/${APP_NAME}/${APP_NAME}_${APP_VERSION}.${PACKAGE_BASE_FILENAME_EXTENSION}"
SYNCTHING_APP_PATH="/home/syncthing/data/${SYNCTHING_APP_DIR}"
SYNCTHING_INSTALL_SCRIPT="syncthingInstall.sh"
SYNCTHING_UNINSTALL_SCRIPT="syncthingUninstall.sh"

# echo "enter c3 sudo password:"
# TODO: read pass
# read -s SUDOPW
SUDOPW=root

# bundle app
./bundleApp.sh ${APP_NAME}

# mkdir and change onwner
CMD="mkdir '${TEMP_PATH}' -p; chown c3.c3 '${TEMP_PATH}'"
${C3_BASE_CMD} 'echo '${SUDOPW}' | sudo -S -s /bin/bash -c "'${CMD}'"'
# copy preInstall.sh script
scp ${SYNCTHING_INSTALL_SCRIPT} ${C3_IP}:${TEMP_PATH}
scp ${SYNCTHING_UNINSTALL_SCRIPT} ${C3_IP}:${TEMP_PATH}
# chown of SYNCTHING_INSTALL_SCRIPT
CMD="chmod a+x '${TEMP_PATH}/${SYNCTHING_INSTALL_SCRIPT}'"
${C3_BASE_CMD} 'echo '${SUDOPW}' | sudo -S -s /bin/bash -c "'${CMD}'"'
CMD="chmod a+x '${TEMP_PATH}/${SYNCTHING_UNINSTALL_SCRIPT}'"
${C3_BASE_CMD} 'echo '${SUDOPW}' | sudo -S -s /bin/bash -c "'${CMD}'"'

# copy package app file
CMD="mkdir '${SYNCTHING_APP_PATH}' -p; chown c3.c3 '${SYNCTHING_APP_PATH}'"
${C3_BASE_CMD} 'echo '${SUDOPW}' | sudo -S -s /bin/bash -c "'${CMD}'"'
scp ${APP_FILEPATH} ${C3_IP}:${SYNCTHING_APP_PATH}

# TODO: this install app, but is better to output commands and launch manually
# run syncthingInstall.sh
# CMD="cd ${TEMP_PATH}; ./${SYNCTHING_INSTALL_SCRIPT} ${APP_NAME} ${SYNCTHING_APP_DIR}"
# ${C3_BASE_CMD} 'echo '${SUDOPW}' | sudo -S -s /bin/bash -c "'${CMD}'"'
printf "\ndone, now to install and uninstall app, launch bellow scripts in path ${TEMP_PATH}\n\n"
printf "  sudo ./syncthingInstall.sh ${APP_NAME} ${SYNCTHING_APP_DIR}\n"
printf "  sudo ./syncthingUninstall.sh ${SYNCTHING_APP_DIR}\n\n"

unset SUDOPW
exit 0
