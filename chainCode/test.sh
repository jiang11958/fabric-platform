#!/bin/bash
############################################
#
# used for chaincode test
# by jeozey 594485991@qq.com
#
############################################
DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ];then
    CURDIR=`dirname $DIRNAME`
else
    CURDIR="`pwd`"/"`dirname $DIRNAME`"
fi
echo $CURDIR

#set variable
networkName="fabric-test-network1"
org="org1"
ordererOrg="orderer.jeozey1.com"

#down sacc test chaincode 
cd /mnt/fabric/resources/chaincodes/
mkdir -p sacc/go
cd sacc/go
wget https://raw.githubusercontent.com/hyperledger/fabric-samples/release-1.4/chaincode/sacc/sacc.go

#package chaincode
container=` kubectl get pod -n ${networkName} | grep cli-${org}|awk '{print $1}' `
kubectl exec -i  $container -n ${networkName} -- rm -f temp.sh	
kubectl exec -i  $container -n ${networkName} -- bash -c 'echo -e " peer chaincode package -n myccone -p github.com/hyperledger/fabric/peer/resources/chaincodes/sacc/go  -v 1.0 myccone.1.0.out \n peer chaincode package -n mycctwo -p github.com/hyperledger/fabric/peer/resources/chaincodes/sacc/go  -v 1.0 mycctwo.1.0.out \n cp *.out resources/chaincodes/ \n ls  resources/chaincodes/ \n" > temp.sh'
kubectl exec -i  $container -n ${networkName} -- bash -c 'sh ./temp.sh'

#package install chaincode and instantiate chainCode
cd $CURDIR
sh run.sh  -s ${networkName} -o org1 -m 3  -f /mnt/fabric/resources/chaincodes/myccone.1.0.out
sh run.sh  -s ${networkName} -o org1 -m 3  -f /mnt/fabric/resources/chaincodes/mycctwo.1.0.out
sh run.sh  -s ${networkName} -o org2 -m 3  -f /mnt/fabric/resources/chaincodes/myccone.1.0.out
sh run.sh  -s ${networkName} -o org3 -m 3  -f /mnt/fabric/resources/chaincodes/mycctwo.1.0.out
sleep 3
sh run.sh  -s ${networkName} -r ${ordererOrg} -o org1 -m 4 -c mychannel1 -n myccone -v 1.0  -i '{"Args":["a","10"]}'  -p "OR ('org1MSP.member','org2MSP.member')"
sleep 5
sh run.sh  -s ${networkName} -r ${ordererOrg} -o org1 -m 4 -c mychannel2 -n mycctwo -v 1.0  -i '{"Args":["a","10"]}'  -p "OR ('org1MSP.member','org3MSP.member')"
 
sleep 5
#invoke chainCode
sh run.sh -s ${networkName} -r ${ordererOrg} -o org2 -m 6 -c mychannel1 -n myccone  -e '{"Args":["set","t1","330"]}' 

sleep 2
#query chainCode
sh run.sh -s ${networkName} -o org1 -m 7 -c mychannel1 -n myccone  -q '{"Args":["query","t1"]}'  