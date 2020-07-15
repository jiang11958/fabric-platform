#!/bin/bash
############################################
#
# get joined channel list of org
# by jeozey 594485991@qq.com
#
############################################

echo $#

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "     sh channel_fun.sh fab org1"
}

if [ $# -ne 2 ];
then
	printHelp
	exit 1
fi

echo $@

networkName=$1
org=$2

container=` kubectl get pod -n ${networkName} | grep cli-${org}|awk '{print $1}' `
result=`kubectl exec -i  $container -n ${networkName} -- bash -c 'peer channel list' ` 
echo "result: $result"



