#!/bin/bash
############################################
#
# for org create channel and join channel
# by jeozey 594485991@qq.com
#
############################################

echo $#
# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "     sh channel.sh fab orderer.example.com cchhlx01 [org1,org2]"
}

if [ $# -ne 4 ];
then
	printHelp
	exit 1
fi

echo $@

CLUSTER_NAME=$1
ORDERER_ORG=$2
CHANNEL_NAME=$3

result=$(echo $4 | grep "[")
if [[ "$result" != "" ]]
then
	t=$4
	str=${t:1:(${#t}-2)}
	str=${str//,/ };
	arr=($str)
	#echo $arr
	#echo ${arr[*]}
	#echo ${#arr[@]}
else
	arr=($4)
fi



for org in ${arr[*]}
do

	container=` kubectl get pod -n fab | grep 'Running' | grep cli-${org} | awk '{print $1}' `
	
	kubectl exec -i  $container -n fab -- rm -f temp.sh
	kubectl exec -i  $container -n fab -- bash -c 'echo -e "rm -f '$CHANNEL_NAME'.block\n	peer channel fetch oldest '$CHANNEL_NAME'.block -c '$CHANNEL_NAME' --orderer orderer0.'$ORDERER_ORG':7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/'$ORDERER_ORG'/orderers/orderer0.'$ORDERER_ORG'/msp/tlscacerts/tlsca.'$ORDERER_ORG'-cert.pem \n if [ ! -f '$CHANNEL_NAME'.block ]; then \n 	peer channel create -o orderer0.'$ORDERER_ORG':7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/'$ORDERER_ORG'/orderers/orderer0.'$ORDERER_ORG'/msp/tlscacerts/tlsca.'$ORDERER_ORG'-cert.pem -c '$CHANNEL_NAME' -f ./resources/channel-artifacts/'$CHANNEL_NAME'_channel.tx \n 	fi \n 	peer channel join -b '$CHANNEL_NAME'.block \n	peer channel update  -c '$CHANNEL_NAME' -f ./resources/channel-artifacts/'$CHANNEL_NAME'_'$org'_MSPanchors.tx -o orderer0.'$ORDERER_ORG':7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/'$ORDERER_ORG'/orderers/orderer0.'$ORDERER_ORG'/msp/tlscacerts/tlsca.'$ORDERER_ORG'-cert.pem \n	" > temp.sh'
	kubectl exec -i  $container -n fab -- bash -c 'sh ./temp.sh'
	#kubectl exec -i  $container -n fab -- cat temp.sh

done


