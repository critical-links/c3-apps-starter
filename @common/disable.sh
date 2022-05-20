# load .env
set -a
. app.env
set +a

validate_root_user

if [ "${SERVICE_STATE}" = "${SERVICE_STATE_DISABLED}" ]; then
  echo "you can't disable a service that is already disabled"
  exit 1
fi

printf "disable ${APP_FRIENDLY_NAME}...\\n"

printf "  save service state\\n"
echo $(cat ${C3_PACKAGE_DATA_FILEPATH} | jq ".state = \"${SERVICE_STATE_DISABLING}\"") > ${C3_PACKAGE_DATA_FILEPATH}

printf "  disable apache reverse proxy ${APP_DOMAIN}.${C3_DOMAIN}...\\n"
cd ${C3_APACHE_SITES_ENABLED}
if [ ! -L "c3app-${APP_NAME}.conf" ]; then
  ${APACHE_DISABLE_HTTP}
fi
if [ ! -L "c3app-${APP_NAME}.com-le-ssl.conf" ]; then
  ${APACHE_DISABLE_HTTPS}
fi
${APACHE_RELOAD_SERVICE}
sleep ${SLEEP_TIME}

printf "  delete dns entry ${APP_DOMAIN}.${C3_DOMAIN}...\\n"
${SAMBA_DELETE_DNS}
sleep ${SLEEP_TIME}

printf "  stop docker stack\\n"
cd ${C3_DOCKER_BASE_PATH}/${APP_NAME}
${DOCKER_DOWN}

printf "  disable monit service\\n"
${MONIT_SERVICE_UNMONITOR}
${MONIT_REMOVE_SYM_LINK}
${MONIT_SERVICE_RELOAD}
sleep ${SLEEP_TIME}

printf "  save service state\\n"
echo $(cat ${C3_PACKAGE_DATA_FILEPATH} | jq ".state = \"${SERVICE_STATE_DISABLED}\"") > ${C3_PACKAGE_DATA_FILEPATH}
