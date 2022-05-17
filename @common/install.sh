# load .env

sleep 2

set -a
. app.env
set +a

validate_root_user

printf "install ${APP_FRIENDLY_NAME}...\\n"

printf "check if target directories exist...\\n"
for dir in "${C3_PACKAGE_EXTRACT_TARGET_DIRS[@]}"
do
	if [ ! -d ${dir} ] 
	then
		mkdir ${dir} -p
	fi	
done

printf "  unpack package files to file system...\\n"
# extract dir files/ package root directories ex etc, srv etc
for dir in "${C3_PACKAGE_EXTRACT_DIRS[@]}"
do
	tar --overwrite -xzf ${PACKAGE_BUNDLE_FILEPATH} -C / ${dir}/
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

# return home
cd ${PWD}