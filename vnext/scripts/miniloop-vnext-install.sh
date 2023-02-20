#!/usr/bin/env bash
# miniloop-vnext-install.sh
#    - install mojaloop vnext version in a light-weight , simple and quick fashion 
#      for demo's testing and development 
#
# refer : @#see @https://github.com/mojaloop/platform-shared-tools            
# Author Tom Daly 
# Date Feb 2023
# TODO/Notes
# - sysctl -w vm.max_map_count=262144 => no -w flag for sysctl on macos 
# - implement trap for sigerr and test 

function check_arch {
  ## check architecture Mojaloop deploys on x64 only today arm is coming  
  arch=`uname -p`
  if [[ ! "$arch" == "x86_64" ]]; then 
    printf " ** Error: Mojaloop is only running on x86_64 today and not yet running on ARM cpus \n"
    printf "    please see https://github.com/mojaloop/project/issues/2317 for ARM status \n"
    printf " ** \n"
    if [[ ! -z "${devmode}" ]]; then 
      printf "devmode Flag set ==> this flag is for mini-loop development only ==> continuing \n"
    else
      exit 1
    fi
  fi
}

function check_user {
  # ensure that the user is not root
  if [ "$EUID" -eq 0 ]; then 
    printf " ** Error: please run $0 as non root user ** \n"
    exit 1
  fi
}

function set_logfiles {
  # set the logfiles
  if [ ! -z ${logfiles+x} ]; then 
    LOGFILE="/tmp/$logfiles.log"
    ERRFILE="/tmp/$logfiles.err"
    echo $LOGFILE
    echo $ERRFILE
  fi 
  touch $LOGFILE
  touch $ERRFILE
  printf "start : mini-loop Mojaloop local install utility [%s]\n" "`date`" >> $LOGFILE
  printf "================================================================================\n" >> $LOGFILE
  printf "start : mini-loop Mojaloop local install utility [%s]\n" "`date`" >> $ERRFILE
  printf "================================================================================\n" >> $ERRFILE

  printf "==> logfiles can be found at %s and %s\n " "$LOGFILE" "$ERRFILE"
}

function mojaloop_infra_setup  {
  # @see https://github.com/mojaloop/platform-shared-tools/blob/main/packages/deployment/docker-compose-infra/README.md
  printf "start : mini-loop Mojaloop-vnext install base infrastructure services [%s]\n" "`date`"  
  # setup the directory structure and .env file 
  dirs_list=( "certs" "esdata01" "kibanadata" "logs"  "tigerbeetle_data" )
  rm -rf $INFRA_DIR_EXEC
  mkdir $INFRA_DIR_EXEC
  for i in "${dirs_list[@]}"; do
    mkdir "$INFRA_DIR_EXEC/$i"
  done
  cp $INFRA_DIR/.env.sample $INFRA_DIR_EXEC/.env 
  ls -la $INFRA_DIR_EXEC
  # make sure the ROOT_VOLUME_DEVICE is using absolute path
  perl -p -i -e 's/ROOT_VOLUME_DEVICE_PATH=.*$/ROOT_VOLUME_DEVICE_PATH=$ENV{INFRA_DIR_EXEC}/' $INFRA_DIR_EXEC/.env
  grep ROOT_VOLUME_DEVICE_PATH $INFRA_DIR_EXEC/.env

  # provision TigerBeetle's data directory 
  docker run -v $INFRA_DIR_EXEC/tigerbeetle_data:/data ghcr.io/tigerbeetledb/tigerbeetle \
                format --cluster=0 --replica=0 /data/0_0.tigerbeetle
  if [[ $? -eq 0 ]]; then 
        printf "TigerBeetle data directory provisioned correctly\n"
  else 
        printf "** Error : TigerBeetle data directory provisioning appears to have failed ** \n"
        exit 1
    fi
} 

function mojaloop_infra_startup {
  # start infra services 
  printf "==> Mojaloop vNext : infrastructure services startup  \n"
  docker-compose -f $INFRA_DIR/docker-compose-infra.yml --env-file $INFRA_DIR_EXEC/.env up -d
  if [[ $? -eq 0 ]]; then 
        printf "TigerBeetle data directory provisioned correctly\n"
  else 
        printf "** Error : TigerBeetle data directory provisioning appears to have failed ** \n"
        exit 1
    fi
}


function mojaloop_infra_shutdown {
  # start infra services 

  docker-compose -f $INFRA_DIR/docker-compose-infra.yml --env-file $INFRA_DIR_EXEC/.env down -d

}


function  install_mojaloop_cross_cutting  {
  printf "start : mini-loop Mojaloop-vnext install horizontal services  [%s]\n" "`date`"

} 

function  install_mojaloop_apps  {
  printf "start : mini-loop Mojaloop-vnext install application [%s]\n" "`date`"

} 

function check_mojaloop_health {
  # verify the health of the deployment 
  for i in "${EXTERNAL_ENDPOINTS_LIST[@]}"; do
    #curl -s  http://$i/health
    if [[ `curl -s  http://$i/health | \
      perl -nle '$count++ while /\"status\":\"OK+/g; END {print $count}' ` -lt 1 ]] ; then
      printf  " ** Error: [curl -s http://%s/health] endpoint healthcheck failed ** \n" "$i"
      exit 1
    else 
      printf "    ==> curl -s http://%s/health is ok \n" $i 
    fi
    sleep 2 
  done 
}

function print_end_banner {
  printf "\n\n****************************************************************************************\n"
  printf "            -- mini-loop Mojaloop local install utility -- \n"
  printf "********************* << END >> ********************************************************\n\n"
}

function print_success_message { 
  printf " ==> %s configuration of mojaloop deployed ok and passes endpoint health checks \n" "$RELEASE_NAME"
  printf "     to execute the helm tests against this now running deployment please execute :  \n"
  printf "     helm -n %s test ml --logs \n" "$NAMESPACE" 
  printf "     \nto uninstall mojaloop please execute : \n"
  printf "     helm delete -n %s ml\n"  "$NAMESPACE"


  printf "\n** Notice and Caution ** \n"
  printf "        mini-loop install scripts have now deployed mojaloop switch to use for  :-\n"
  printf "            - trial \n"
  printf "            - test \n"
  printf "            - education and demonstration \n"
  printf "        This installation should *NOT* be treated as a *production* deployment as it is designed for simplicity \n"
  printf "        To be clear: Mojaloop itself is designed to be robust and secure and can be deployed securely \n"
  printf "        This mini-loop install is neither secure nor robust. \n"
  printf "        With this caution in mind , welcome to the full function of Mojaloop\n"
  printf "        please see : https://mojaloop.io/ for more information, resources and online training\n"

  print_end_banner 
  
}

################################################################################
# Function: showUsage
################################################################################
# Description:		Display usage message
# Arguments:		none
# Return values:	none
#
function showUsage {
	if [ $# -lt 0 ] ; then
		echo "Incorrect number of arguments passed to function $0"
		exit 1
	else
echo  "USAGE: $0 -m <mode> 
Example 1 : $0 -m install_ml  # install mojaloop (vnext) 
Example 2 : $0 -m delete_ml   # delete mojaloop  (vnext)
 
Options:
-m mode ............ install_ml|delete_ml
-h|H ............... display this message
"
	fi
}

################################################################################
# MAIN
################################################################################

##
# Environment Config & global vars 
##
LOGFILE="/tmp/miniloop-install.log"
ERRFILE="/tmp/miniloop-install.err"
SCRIPTS_DIR="$( cd $(dirname "$0")/../scripts ; pwd )"
DEPLOYMENT_DIR=$HOME/platform-shared-tools/packages/deployment
export INFRA_DIR=$HOME/platform-shared-tools/packages/deployment/docker-compose-infra
export INFRA_DIR_EXEC=$HOME/platform-shared-tools/packages/deployment/docker-compose-infra/exec


echo $INFRA_DIR
#ETC_DIR="$( cd $(dirname "$0")/../etc ; pwd )"

# Process command line options as required
while getopts "m:l:hH" OPTION ; do
   case "${OPTION}" in
        l)  logfiles="${OPTARG}"
        ;;
        m)  mode="${OPTARG}"
        ;;
        h|H)	showUsage
                exit 0
        ;;
        *)	echo  "unknown option"
                showUsage
                exit 1
        ;;
    esac
done

printf "\n\n****************************************************************************************\n"
printf "            -- mini-loop Mojaloop (vnext) install utility -- \n"
printf "********************* << START  >> *****************************************************\n\n"
#check_arch
check_user
#set_logfiles 
printf "\n"

if [[ "$mode" == "delete_ml" ]]; then
  delete_mojaloop
  print_end_banner
elif [[ "$mode" == "install_ml" ]]; then
  printf "start : mini-loop Mojaloop local install utility [%s]\n" "`date`" >> $LOGFILE
  mojaloop_infra_setup
  mojaloop_infra_startup
  install_mojaloop_cross_cutting
  install_mojaloop_apps
  #check_mojaloop_health
  #print_success_message 
elif [[ "$mode" == "check_ml" ]]; then
  check_mojaloop_health
else 
  printf "** Error : wrong value for -m ** \n\n"
  showUsage
  exit 1
fi 