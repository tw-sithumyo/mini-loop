#!/usr/bin/env bash
# cleanup.sh
#    - cleanup after mojaloop vnext install
#    - this script requires sudo to operate properly 
#
# refer : @#see @https://github.com/mojaloop/platform-shared-tools            
# Author Tom Daly 
# Date Feb 2023
# 


function delete_docker {
  # @TODO : this needs to fully remove docker ready for re-install 
  #          @#see  https://docs.docker.com/engine/install/ubuntu/
  docker system prune -f ; docker volume prune -f ;docker rm -f -v $(docker ps -q -a)
  docker volume ls | grep ml_ | xargs docker volume rm -f
} 

function delete_mojaloop_vnext {
  printf "==> Mojaloop vNext : infrastructure services shutdown & cleanup \n"
  printf "  Shutting down mojaloop vNext infra services and cleanup artifacts \n"
  $DOCKER_COMPOSE -f $INFRA_DIR/docker-compose-infra.yml --env-file $INFRA_DIR_EXEC/.env down 
  if [[ $? -eq 0 ]]; then 
        printf "  infrastructure services shutdown\n"
  else 
        printf "** Error : infrastructure services shutdown appears to have failed ** \n"
        printf "** you can try manually with the command :- \n"
        printf "** $DOCKER_COMPOSE -f $INFRA_DIR/docker-compose-infra.yml --env-file $INFRA_DIR_EXEC/.env down \n"
        exit 1 
  fi
  printf "removing INFRA working dir : $INFRA_DIR_EXEC \n"
  rm -rf $INFRA_DIR_EXEC
  # TODO : what about docker volumes ????

  printf "  Shutting down mojaloop cross cutting services and cleanup artifacts \n"
  $DOCKER_COMPOSE -f $CROSS_CUT_DIR_EXEC/docker-compose-cross-cutting.yml --env-file $CROSS_CUT_DIR_EXEC/.env stop
  if [[ $? -eq 0 ]]; then 
        printf "  cross cutting services shutdown\n"
  else 
        printf "** Error : cross cutting services shutdown appears to have failed ** \n"
        printf "** you can try manually with the command  \n"
        printf "** [%s]  -f [%s]/docker-compose-cross-cutting.yml --env-file [%s]/.env stop  \n" $DOCKER_COMPOSE $CROSS_CUT_DIR_EXEC $CROSS_CUT_DIR_EXEC
        printf "** then \$sudo rm -rf $CROSS_CUT_DIR_EXEC\n"
        exit 1 
  fi
  printf "removing cross cutting (horizontal services) working dir : $CROSS_CUT_DIR_EXEC"
  rm -rf $CROSS_CUT_DIR_EXEC
  # TODO : what about docker volumes ????

} 
function delete_mojaloop_vnext_repo {
  printf "removing local mojaloop vNext workspace (i.e. local repo) [%s]: " $REPO_DIR
  rm -rf $REPO_DIR 
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
Example 1 : $0 -m delete_ml   # delete mojaloop  (vnext)
Example 2 : $0 -m delete_repo # delete the local mojaloop vNext workspace (repo). 
Example 2 : $0 -m delete_docker # delete the docker install and everything associated with it. 
 
Options:
-m mode ............ delete_ml|delete_repo|delete_docker
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
REPO_DIR=$HOME/platform-shared-tools
DEPLOYMENT_DIR=$HOME/platform-shared-tools/packages/deployment
export INFRA_DIR=$HOME/platform-shared-tools/packages/deployment/docker-compose-infra
export INFRA_DIR_EXEC=$HOME/platform-shared-tools/packages/deployment/docker-compose-infra/exec
export CROSS_CUT_DIR=$HOME/platform-shared-tools/packages/deployment/docker-compose-cross-cutting
export CROSS_CUT_DIR_EXEC=$HOME/platform-shared-tools/packages/deployment/docker-compose-cross-cutting/exec

DOCKER_COMPOSE=""
docker-compose > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
      DOCKER_COMPOSE=docker-compose 
else
      DOCKER_COMPOSE="docker compose" 
fi
echo $DOCKER_COMPOSE

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

if [[ "$mode" == "delete_ml" ]]; then
  delete_mojaloop_vnext
  print_end_banner
elif [[ "$mode" == "delete_repo" ]]; then
  delete_mojaloop_vnext_repo
elif [[ "$mode" == "delete_docker" ]]; then
  delete_docker
else 
  printf "** Error : wrong value for -m ** \n\n"
  showUsage
  exit 1
fi 