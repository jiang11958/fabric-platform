#!/bin/bash


function getCaPems(){
	declare -A caPems
	
	##################### get orderer ca pem #################################
	domain=`echo ${1}|jq ".orderer.domain" | sed 's/\"//g'`
	pem=`cat /mnt/fabric/resources/fabric-ca-server/${domain}/ca-cert.pem`
	caPems["${domain}"]="$pem"
	
	
	##################### get org ca pem #################################
	for k in $(echo ${1}|jq '.orgs | keys | .[]' ); do
		value=$(echo ${1}|jq -r ".orgs[$k]");
		domain=$(jq -r '.domain' <<< "$value");
		echo $domain
		pem=`cat /mnt/fabric/resources/fabric-ca-server/${domain}/ca-cert.pem`
		caPems["${domain}"]="$pem"
	done

	pemsJson='{"pems":[]}'
	local i=0
	for key in $(echo ${!caPems[*]})
	do

		p="${caPems[$key]}"
		t=$(jq -Rrn --arg orgName "$key" 	--arg pem "$p"	'{"orgName":$orgName,"pem":$pem}')
		pemsJson=$(echo $pemsJson| jq   -c --argjson m "$t" '.pems['$i']  |= . + $m' )
		let i++ 
	done
	
	echo $pemsJson
	echo "getCaPems done"
}

declare -A servicePorts
function getServicePort(){

	serversJson='{"servers":[]}'
	
	servicePorts=` kubectl get svc -n $clusterName --show-labels | grep -v CLUSTER | awk '{split($5,port,/[:/]/); match($0,/.+domain=([^,]+)/,dom); if(dom[1] != "") print dom[1]":"port[2]}'`
	#echo $servicePorts
	arr=($servicePorts)
	
	local i=0
	for domain in ${arr[*]}
	do
	    #echo $domain
		t=(${domain//:/ })
		#echo ${#t[@]} 
		#echo ${t[0]} ${t[1]}
		
		t=$(jq -Rrn --arg d "${t[0]}" 	--arg p "${t[1]}"	'{"domain":$d,"port":$p}')

		serversJson=$(echo $serversJson| jq   -c --argjson m "$t" '.servers['$i']  |= . + $m' )
		let i++ 
	done
	echo $serversJson
	echo "getServicePort done"
}

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "     sh run.sh \"{\\\"network\\\":{\\\"name\\\":\\\"fab\\\"},\\\"org\\\":{\\\"name\\\":\\\"org1\\\",\\\"mspName\\\":\\\"org1MSP\\\",\\\"domain\\\":\\\"org1.example.com\\\",\\\"port\\\":\\\"7051\\\"},\\\"orderer\\\":{\\\"name\\\":\\\"orderer\\\",\\\"count\\\":\\\"1\\\",\\\"domain\\\":\\\"orderer.example.com\\\"},\\\"orgs\\\":[{\\\"name\\\":\\\"org1\\\",\\\"mspName\\\":\\\"org1MSP\\\",\\\"domain\\\":\\\"org1.example.com\\\",\\\"port\\\":\\\"7051\\\",\\\"count\\\":\\\"1\\\"},{\\\"name\\\":\\\"org2\\\",\\\"mspName\\\":\\\"org2MSP\\\",\\\"domain\\\":\\\"org2.example.com\\\",\\\"port\\\":\\\"7051\\\",\\\"count\\\":\\\"1\\\"},{\\\"name\\\":\\\"org3\\\",\\\"mspName\\\":\\\"org3MSP\\\",\\\"domain\\\":\\\"org3.example.com\\\",\\\"port\\\":\\\"7051\\\",\\\"count\\\":\\\"1\\\"}],\\\"channels\\\":[{\\\"name\\\":\\\"mychannel2\\\",\\\"orgs\\\":[\\\"org1\\\",\\\"org3\\\"]},{\\\"name\\\":\\\"mychannel1\\\",\\\"orgs\\\":[\\\"org1\\\",\\\"org2\\\"]}]}\" "
}

if [ $# -ne 1 ];
then
	printHelp
	exit 1
fi

clusterName=`echo $1|jq '.network.name' | sed 's/\"//g'`
getCaPems $@
getServicePort $@


ansible-playbook generate_profile.yaml -e "$pemsJson" -e "$serversJson" -e $@
