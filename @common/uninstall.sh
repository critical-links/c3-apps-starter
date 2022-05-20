# load .env
set -a
. app.env
set +a

validate_root_user

printf "uninstall ${APP_FRIENDLY_NAME}...\\n"

# remove docker network before disable
printf "  remove docker network ${DOCKER_NETWORK}\n"
${DOCKER_REMOVE_NETWORK}
sleep ${SLEEP_TIME}

# disable app
printf "  disable app\n"
./disable.sh ${SYNCTHING_APP_DIR}

retVal=$?
if [ $retVal -ne 0 ]; then
  exit $retVal
fi

printf "  stop docker stack\\n"
cd ${C3_DOCKER_BASE_PATH}/${APP_NAME}
${DOCKER_TEAR_DOWN}
sleep ${SLEEP_TIME}

# this is not needed anymore, docker down already clean's up
# printf "  remove docker images\\n"
# for image in "${DOCKER_IMAGES[@]}"
# do
#   printf "  remove image ${image}\\n"
#   docker image rm ${image}
# done

export C3_PACKAGE_REMOVE_FILES=(
  # files
  "${C3_APACHE_SITES_AVAILABLE}/${PACKAGE_BASE_PREFIX}-${APP_NAME}.conf"
  "${C3_APACHE_SITES_AVAILABLE}/${PACKAGE_BASE_PREFIX}-${APP_NAME}.com-le-ssl.conf"
  "${C3_APACHE_SITES_ENABLED}/${PACKAGE_BASE_PREFIX}-${APP_NAME}.conf"
  "${C3_APACHE_SITES_ENABLED}/${PACKAGE_BASE_PREFIX}-${APP_NAME}.com-le-ssl.conf"
  "${C3_MONIT_CONF_ENABLED_PATH}/host-${PACKAGE_BASE_PREFIX}-${APP_NAME}"
  "${C3_MONIT_CONF_AVAILABLE_PATH}/host-${PACKAGE_BASE_PREFIX}-${APP_NAME}"
  # dirs
  "${C3_DOCKER_BASE_PATH}/${APP_NAME}/"
  "${C3_PACKAGE_BASE_DATA_PATH}/${SYNCTHING_APP_DIR}"
)

echo "  removing files, directories and symbolic links..."
for fileOrDir in "${C3_PACKAGE_REMOVE_FILES[@]}"
do
  # check if dir
  if [ -d "${fileOrDir}" ]; then
    echo "    removing directory ${fileOrDir}..."
    rm ${fileOrDir} -r
  fi
  # check if file exists
  if test -f "${fileOrDir}"; then
    rm ${fileOrDir}
  fi
  # check if is a symbolic link
  if [[ -L "${fileOrDir}" ]]; then
    echo "    removing symbolic link ${fileOrDir}..."
    if [[ -e "${fileOrDir}" ]]; then
      unlink ${fileOrDir}
    else
      unlink ${fileOrDir}
    fi
  fi
done
