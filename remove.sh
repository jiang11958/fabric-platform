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

function removeNetWork(){

	echo "# remove fabric network"
	ansible-playbook -i $ANSIBLE_INVENTORY  $CURDIR/ansible/remove.yaml -e "$1"
	
}

#Print the usage message
function printHelp () {
  echo "Usage: "
  echo "   sh remove.sh \"{'cluster':{'name':'fab'}}\""
}

if [ $# -ne 1 ];
then
	printHelp
	exit
fi


removeNetWork $@