#!/usr/bin/env bash
# cleanup.sh
#    - cleanup after mojaloop vnext install
#    - this script requires sudo to operate properly 
#
# refer : @#see @https://github.com/mojaloop/platform-shared-tools            
# Author Tom Daly 
# Date Feb 2023
# 


function mojaloop_vnext_cleanup {
  docker system prune -f ; docker volume prune -f ;docker rm -f -v $(docker ps -q -a)
  docker volume ls | grep ml_ | xargs docker volume rm -f
  rm -rf $INFRA_DIR_EXEC
} 


function print_end_banner {
  printf "\n\n****************************************************************************************\n"
  printf "            -- mini-loop Mojaloop vnext cleanup  -- \n"
  printf "********************* << END >> ********************************************************\n\n"
}

function print_success_message { 
  printf " ==> %s configuration of mojaloop deployed ok and passes endpoint health checks \n" "$RELEASE_NAME"

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

if [[ "$mode" == "cleanup_ml" ]]; then
  mojaloop_vnext_cleanup
  print_end_banner
else 
  printf "** Error : wrong value for -m ** \n\n"
  showUsage
  exit 1
fi 