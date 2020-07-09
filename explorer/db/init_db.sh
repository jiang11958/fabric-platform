#!/bin/sh
cd /fabric/config/explorer/db/

apk update
apk add jq
apk add nodejs
apk add sudo
rm -rf /var/cache/apk/*
chmod +x ./createdb.sh
ls -al
./createdb.sh
