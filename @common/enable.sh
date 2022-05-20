# load .env
set -a
. app.env
set +a

validate_root_user

if [[ -f ${C3_PACKAGE_DATA_FILEPATH} && "${SERVICE_STATE}" = "${SERVICE_STATE_ENABLED}" ]]; then
  echo "you can't enable a service that is already enable"
  exit 1
fi

while [ ! -d  ${C3_DOCKER_APP_PATH} ]
do
	printf "waiting for docker folder ${C3_DOCKER_APP_PATH}\n"
  sleep ${SLEEP_TIME}
done

printf "enable ${APP_FRIENDLY_NAME}...\\n"
sleep ${SLEEP_TIME}

printf "  save service state\\n"
echo $(cat ${C3_PACKAGE_DATA_FILEPATH} | jq ".state = \"${SERVICE_STATE_ENABLING}\"") > ${C3_PACKAGE_DATA_FILEPATH}
sleep ${SLEEP_TIME}

printf "  activate apache reverse proxy ${APP_DOMAIN}.${C3_DOMAIN}...\\n"
cd ${C3_APACHE_SITES_ENABLED}
if [ ! -L "c3app-${APP_NAME}.conf" ]; then
  ${APACHE_ENABLE_HTTP}
fi
if [ ! -L "c3app-${APP_NAME}.com-le-ssl.conf" ]; then
  ${APACHE_ENABLE_HTTPS}
fi
${APACHE_RELOAD_SERVICE}
sleep ${SLEEP_TIME}

printf "  add dns entry ${APP_DOMAIN}.${C3_DOMAIN}...\\n"
${SAMBA_ADD_DNS}
sleep ${SLEEP_TIME}

printf "  run docker stack\\n"
cd ${C3_DOCKER_BASE_PATH}/${APP_NAME}
${DOCKER_UP}
sleep ${SLEEP_TIME}

printf "  enable monit service\\n"
${MONIT_CREATE_SYM_LINK}
${MONIT_SERVICE_RELOAD}
${MONIT_SERVICE_MONITOR}
sleep 2

printf "  save service state\\n"
echo $(cat ${C3_PACKAGE_DATA_FILEPATH} | jq ".state = \"${SERVICE_STATE_ENABLED}\"") > ${C3_PACKAGE_DATA_FILEPATH}
