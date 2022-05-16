#!/bin/bash

if [ -z "${1}" ] || [ -z "${2}" ]; then
  echo "missing require parameter 'appName' and 'port'"
  echo "ex '${0} scratch 8080'"
  exit 0
fi

if [ -d "${1}" ]; then
  message="error app directory '${1}' already exists, remove old directory and continue?"
  printf "> $message (Yes/No) " >&2
  printf "\n"
  while [ -z "$result" ] ; do
    read -s -n 1 choice
    case "$choice" in
      y|Y ) result='Y'; rm ${1} -r; break ;;
      n|N ) result='N'; exit 0 ; break ;;
    esac
  done
fi

APP_NAME="${1}"
APP_PORT="${2}"
FIND_APP_NAME="template-app-name"
FIND_APP_PORT="8088"
RENAME_FILENAMES=( 
  ${APP_NAME}/etc/apache2/sites-available/c3app-${FIND_APP_NAME}.com-le-ssl.conf 
  ${APP_NAME}/etc/apache2/sites-available/c3app-${FIND_APP_NAME}.conf 
  ${APP_NAME}/etc/monit/conf-available/host-c3app-${FIND_APP_NAME} 
  ${APP_NAME}/srv/docker/thirdparty/${FIND_APP_NAME}
)
REPLACE_FILENAMES=(
  ${APP_NAME}/etc/apache2/sites-available/c3app-${APP_NAME}.com-le-ssl.conf
  ${APP_NAME}/etc/apache2/sites-available/c3app-${APP_NAME}.com-le-ssl.conf
  ${APP_NAME}/etc/apache2/sites-available/c3app-${APP_NAME}.conf
  ${APP_NAME}/etc/monit/conf-available/host-c3app-${APP_NAME}
  ${APP_NAME}/srv/docker/thirdparty/${APP_NAME}/docker-compose.yml
  ${APP_NAME}/srv/docker/thirdparty/${APP_NAME}/.env
  ${APP_NAME}/app.env
  ${APP_NAME}/bundle.env
  ${APP_NAME}/etc/monit/conf-available/host-c3app-${APP_NAME}
)
# copy template
printf "creating app structure...\n";
cp @template/ ${1} -R

# rename files
printf "rename files...\n";
for i in "${RENAME_FILENAMES[@]}"
do
  :
  NEW_FILE_NAME=$(echo ${i}|sed "s/${FIND_APP_NAME}/${APP_NAME}/g")
  CMD="mv ${i} ${NEW_FILE_NAME}"
  # echo $CMD
  ${CMD}
done

# find replace
printf "replace files files...\n";
for i in "${REPLACE_FILENAMES[@]}"
do
  :
  sed -i -- "s/${FIND_APP_NAME}/${APP_NAME}/g" ${i}
  sed -i -- "s/${FIND_APP_PORT}/${APP_PORT}/g" ${i}
done

printf "done\n\n";
printf "after bootstrap new app directory structure with ${0} we must proceed to change/tweak all the other files that can't be automatically changed/generated\n\n- ${APP_NAME}/etc/apache2/sites-available/c3app-${APP_NAME}.com-le-ssl.conf\n- ${APP_NAME}/srv/docker/thirdparty/${APP_NAME}/docker-compose.yml\n\n"
