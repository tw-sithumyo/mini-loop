#!/usr/bin/env bash
# install-docker.sh
#    - install docker on ubuntu 22.04 
#    - this script requires sudo to operate properly 
#
# refer : @#see  https://docs.docker.com/engine/install/ubuntu/     
# Author Tom Daly 
# Date Feb 2023
# 

function uninstall_docker {
  printf "uninstalling docker from system \n"
  apt-get remove -y docker docker-engine docker.io containerd runc

}

function install_docker {
  printf "installing docker engine \n"
  apt-get update
  apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  mkdir -m 0755 -p /etc/apt/keyrings  
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  chmod a+r /etc/apt/keyrings/docker.gpg
  apt-get update

  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
Example 1 : $0 -m cleanup_ml   # delete mojaloop  (vnext)
 
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
HOME=/home/ubuntu
SCRIPTS_DIR="$( cd $(dirname "$0")/../scripts ; pwd )"
DEPLOYMENT_DIR=$HOME/platform-shared-tools/packages/deployment
export INFRA_DIR=$HOME/platform-shared-tools/packages/deployment/docker-compose-infra
export INFRA_DIR_EXEC=$HOME/platform-shared-tools/packages/deployment/docker-compose-infra/exec

# Process command line options as required
while getopts "m:hH" OPTION ; do
   case "${OPTION}" in
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
printf "            -- mini-loop Mojaloop (vnext) cleanup  utility -- \n"
printf "********************* << START  >> *****************************************************\n\n"

# ensure we are running as root 
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

if [[ "$mode" == "install" ]]; then
  install_docker
  print_end_banner
elif [[ "$mode" == "uninstall" ]]; then 
  uninstall_docker
else 
  printf "** Error : wrong value for -m ** \n\n"
  showUsage
  exit 1
fi 