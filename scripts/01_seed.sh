#!/usr/bin/env bash

export PATH=/snap/bin:$PATH
POSTMAN_ENV_FILE=/vagrant/postman/environments/Mojaloop-Local.postman_environment.json
POSTMAN_COLLECTION_DIR=/vagrant/postman

echo "-== Creating Hub Accounts ==-"
newman run --delay-request=2000 \
--environment=$POSTMAN_ENV_FILE \
$POSTMAN_COLLECTION_DIR/New-Deployment-FSP_Setup_MojaloopSims.postman_collection.json
