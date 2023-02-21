#!/usr/bin/env bash

# cat /tmp/fred22
# if [[ $? -ne 0 ]]; then
#       printf "there is an error \n"
#       exit 1 
# else
#       printf "it was ok  \n"
# fi
# if command -v docker-compose >/dev/null 2>&1; then
#   export DOCKER_COMPOSE=docker-compose
# elif docker-compose version >/dev/null 2>&1; then
#   export DOCKER_COMPOSE=docker-compose
# else
#   echo "Error: 'docker-compose' command not found"
#   exit 1
# fi

# for file in "$1"/*; do
#   [[ -x "$file" ]] && rm -- "$file"
# done

DOCKER_COMPOSE=""
docker-compose > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
      DOCKER_COMPOSE=docker-compose 
else
      DOCKER_COMPOSE="docker compose" 
fi
echo $DOCKER_COMPOSE