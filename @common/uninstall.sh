# load .env
set -a
. app.env
set +a

validate_root_user

printf "uninstall ${APP_FRIENDLY_NAME}...\\n"

# local install, only occurs if we create a custom pre uninstall script
PRE_UNINSTALL="uninstall_pre.sh"
if [ -f "${PRE_UNINSTALL}" ]; then
	echo "running PRE uninstall script ${PRE_UNINSTALL}"
	./${PRE_UNINSTALL} ${SYNCTHING_APP_DIR}
fi

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

# always remove docker network before disable
printf "  remove docker network ${DOCKER_NETWORK}\n    "
${DOCKER_REMOVE_NETWORK}
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

# local install, only occurs if we create a custom post uninstall script
# warn: must be here, before removing files, dirs, symlinks stuff, else uninstall_post.sh is deleted when reach this point
POST_UNINSTALL="uninstall_post.sh"
if [ -f "${POST_UNINSTALL}" ]; then
	echo "running post uninstall script ${POST_UNINSTALL}"
	./${POST_UNINSTALL} ${SYNCTHING_APP_DIR}
fi

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
