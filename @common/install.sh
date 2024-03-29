# load .env

sleep 2

set -a
. app.env
set +a

validate_root_user

printf "install ${APP_FRIENDLY_NAME}...\\n"

# local install, only occurs if we create a custom pre install script
PRE_INSTALL="install_pre.sh"
if [ -f "${PRE_INSTALL}" ]; then
	echo "running PRE install script ${PRE_INSTALL}"
	./${PRE_INSTALL} ${SYNCTHING_APP_DIR}
fi

printf "check if target directories exist...\\n"
for dir in "${C3_PACKAGE_EXTRACT_TARGET_DIRS[@]}"
do
	if [ ! -d ${dir} ];	then
		mkdir ${dir} -p
	fi
done

printf "  unpack package files to filesystem...\\n"
# extract dir files/ package root directories ex etc, srv etc
for dir in "${C3_PACKAGE_EXTRACT_DIRS[@]}"
do
	if [ "${dir}" == "docker" ]; then
		# extract to C3_DOCKER_BASE_PATH_ROOT
		tar --overwrite -xzf ${PACKAGE_BUNDLE_FILEPATH} -C ${C3_DOCKER_BASE_PATH_ROOT} ${dir}/
	else
		# extract to / root
		tar --overwrite -xzf ${PACKAGE_BUNDLE_FILEPATH} -C / ${dir}/
	fi
	sleep ${SLEEP_TIME}
done

# create docker network before enable, ch4eck if exists first
printf "docker network ${DOCKER_NETWORK}\n"
NETWORK_EXISTS=$($DOCKER_CHECK_NETWORK)
if [[ -z ${NETWORK_EXISTS} || -z ${NETWORK_EXISTS+x} ]]
then 
	printf "  creating network ${DOCKER_NETWORK} network id:"
	${DOCKER_CREATE_NETWORK}
else
	printf "  skip creating network ${DOCKER_NETWORK}\n"
fi

# auto launch enable script on install
./enable.sh ${SYNCTHING_APP_DIR}

# local install, only occurs if we create a custom post install script
POST_INSTALL="install_post.sh"
if [ -f "${POST_INSTALL}" ]; then
	echo "running post install script ${POST_INSTALL}"
	./${POST_INSTALL} ${SYNCTHING_APP_DIR}
fi

# return home
cd ${PWD}
