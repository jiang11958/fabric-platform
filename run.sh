#!/bin/bash
DIRNAME=$0
if [ "${DIRNAME:0:1}" = "/" ];then
    CURDIR=`dirname $DIRNAME`
else
    CURDIR="`pwd`"/"`dirname $DIRNAME`"
fi
echo $CURDIR

export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_INVENTORY="ansible/inventory/hosts"

function startNetWork(){

	echo "# init hosts"
	ansible-playbook $CURDIR/ansible/init.yaml -e "$1"

	echo "# start fabric network"
	ansible-playbook -i $ANSIBLE_INVENTORY  $CURDIR/ansible/start.yaml -e "$1"
	
}

#Print the usage message
function printHelp () {
  echo "Usage: "
  echo "   sh run.sh \"{'cluster':{'name':'fab'},'nfs':{'domain':'','ip':'39.108.169.129','path':'/nfs/fabric/fab','export':'172.18.29.0/24'},'orderer':{'name':'orderer','type':'solo','count':'1','domain':'orderer.example.com','password':'12345678','batchTimeout':'2','maxMessageCount':'10','absoluteMaxBytes':'99','preferredMaxBytes':'512','orderers':[{'name':'orderer0.orderer.example.com','port':'7050'}]},'orgs':[{'name':'org1','mspName':'org1MSP','domain':'org1.example.com','port':'7051','count':'1'},{'name':'org2','mspName':'org2MSP','domain':'org2.example.com','port':'7051','count':'1'},{'name':'org3','mspName':'org3MSP','domain':'org3.example.com','port':'7051','count':'1'}],'channels':[{'name':'cchhlx01','orgs':['org1','org3']},{'name':'cczxst01','orgs':['org1','org2']}]}\""
}

if [ $# -ne 1 ];
then
	printHelp
	exit
fi


startNetWork $@