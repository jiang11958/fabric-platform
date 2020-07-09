#!/bin/sh
mkdir -p /opt/explorer/app/platform/fabric/
mkdir -p /tmp/

mv /opt/explorer/app/platform/fabric/config.json /opt/explorer/app/platform/fabric/config.json.vanilla
cp -r /fabric/config/explorer/app/config/* /opt/explorer/app/platform/fabric/

cd /opt/explorer
echo $EXPLORER_APP_PATH
pwd

node /opt/explorer/main.js 

tail -f ./logs/console/console.log
#tail -f /dev/null
