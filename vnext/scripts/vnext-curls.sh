#!/usr/bin/env bash
# vnext-curls.sh
#        
# Author Tom Daly 
# Date Feb 2023
# 


function mojaloop_vnext_curls {
  # Create the logging index
  curl -i --insecure -X PUT "https://localhost:9200/ml-logging/" -u "elastic" -H "Content-Type: application/json" --data-binary "@$INFRA_DIR/es_mappings_logging.json" --user "elastic:elasticSearchPas42"
  # Create the auditing index
  curl -i --insecure -X PUT "https://localhost:9200/ml-auditing/" -u "elastic" -H "Content-Type: application/json" --data-binary "@$INFRA_DIR/es_mappings_auditing.json" --user "elastic:elasticSearchPas42"
} 


function print_end_banner {
  printf "\n\n****************************************************************************************\n"
  printf "            -- mini-loop Mojaloop vnext curl commands -- \n"
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
Example 1 : $0 -m curls   # curls commands (vnext)
 
Options:
-m mode ............ curls
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
printf "            -- mini-loop Mojaloop (vnext) curls utility -- \n"
printf "********************* << START  >> *****************************************************\n\n"


if [[ "$mode" == "curls" ]]; then
  mojaloop_vnext_curls
  print_end_banner
else 
  printf "** Error : wrong value for -m ** \n\n"
  showUsage
  exit 1
fi 