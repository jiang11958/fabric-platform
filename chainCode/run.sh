#!/bin/bash
############################################
#
# used for chaincode function
# by jeozey 594485991@qq.com
#
############################################

function parserToJson(){
	echo $1
	result=$1
	
	json='{"chainCodes":[]}'
	oldifs="$IFS"
	IFS=$'\n'

	local i=0
	for str in $result 
	do 
	    if [[ $str == *Name* ]] ; then
			#echo "r: $str"	
			Name=`echo $str | awk '{match($0,/Name:([^,]+)/,n); print n[1]}'`
			
			Version=`echo $str | awk '{match($0,/.+Version:([^,]+)/,n); print n[1]}'`
			
			Id=`echo $str | awk '{match($0,/.+Id:([^,]+)/,n); print n[1]}'`
			
			t=$(jq -Rrn --arg Name "$Name" 	--arg Version "$Version"	'{"Name":$Name,"Version":$Version}')
			json=$(echo $json| jq   -c --argjson m "$t" '.channels['$i']  |= . + $m' )
			
			let i++
		fi
		
	done
	#echo $json
	IFS="$oldifs"
	
}
function getChainCodeInstalled(){
	result=`kubectl exec -i  $container -n ${networkName} -- bash -c 'peer chaincode list --installed' ` 
	echo "result: $result"
	
	parserToJson "$result"
	echo $json
}

function getChainCodeInstantiatd(){
	command="peer chaincode list --instantiated -C $channelName"
	result=`kubectl exec -i  $container -n ${networkName} --  $command ` 
	echo "result: $result"
	
	parserToJson "$result"
	echo $json
}

function installChainCode(){
	name=`echo ${chainCodePath##*/}`
	echo $name
	
	
	kubectl exec -i  $container -n ${networkName} -- rm -f temp.sh	
	kubectl exec -i  $container -n ${networkName} -- bash -c 'echo -e "if [ ! -f resources/chaincodes/'$name' ];then\n echo "chainCode not exist"; exit 1;\n fi \n cp  resources/chaincodes/'$name' ./ \n peer chaincode install '$name' \n" > temp.sh'
	kubectl exec -i  $container -n ${networkName} -- bash -c 'sh ./temp.sh'
}

function instantiateChainCode(){
    pem="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${orderer}/orderers/orderer0.${orderer}/msp/tlscacerts/tlsca.${orderer}-cert.pem"
	kubectl exec -i  $container -n ${networkName} -- peer chaincode instantiate -o "orderer0.${orderer}:7050" --tls --cafile "$pem" -n "$chainCodeName" -v "$version" -c "$initContent" -C "$channelName"  -P "$policy"
}

function upgradeChainCode(){
	pem="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${orderer}/orderers/orderer0.${orderer}/msp/tlscacerts/tlsca.${orderer}-cert.pem"
	kubectl exec -i  $container -n ${networkName} -- peer chaincode upgrade -o "orderer0.${orderer}:7050" --tls --cafile "$pem" -n "$chainCodeName" -v "$version" -c "$initContent" -C "$channelName"  -P "$policy"
}

function invokeChainCode(){
	pem="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${orderer}/orderers/orderer0.${orderer}/msp/tlscacerts/tlsca.${orderer}-cert.pem"
	result=` kubectl exec -i  $container -n ${networkName} -- peer chaincode invoke -o orderer0.${orderer}:7050 --tls --cafile "$pem" -n "$chainCodeName" -C "$channelName"  -c "$invokeContent" `
	echo "result: $result"
	echo "invokeContent: $invokeContent"
}

function queryChainCode(){
	result=` kubectl exec -i  $container -n ${networkName} -- peer chaincode query -n "$chainCodeName" -C "$channelName"  -c "$queryContent" `
	echo "result: $result"
	echo "queryContent: $queryContent"
}

usage() { echo "Usage: $0 [-s fab] [-o org1] [-m 1] [-c cchhlx01] [-f /mnt/fabric/resources/chaincodes/zxst01bills.1.0.out]" 1>&2; exit 1; }
usageForInstall() { echo "Usage: $0 [-s fab] [-o org1] [-m 3] [-f /mnt/fabric/resources/chaincodes/zxst01bills.1.0.out]" 1>&2; exit 1; }
usageForInstantiate() { echo "Usage: $0 [-s fab] [-r orderer0.orderer.example.com:7050] [-o org1] [-m 4] [-c cchhlx01] [-n hhlx01bills] [-v 1.0] [-i {\"Args\":[\"a\",\"10\"]} ] [-p OR ('org1MSP.member','org3MSP.member') ] " 1>&2; exit 1; }
usageForUpgrade() { echo "Usage: $0 [-s fab] [-r orderer0.orderer.example.com:7050] [-o org1] [-m 5] [-c cchhlx01] [-n hhlx01bills] [-v 1.0] [-i {\"Args\":[\"a\",\"10\"]} ] [-p OR ('org1MSP.member','org3MSP.member') ] " 1>&2; exit 1; }
usageForInvoke() { echo "Usage: $0 [-s fab] [-r orderer0.orderer.example.com:7050] [-o org1] [-m 6] [-c cchhlx01] [-n hhlx01bills]  [-e {\"Args\":[\"set\",\"c\",\"10\"]} ] " 1>&2; exit 1; }
usageForQuery() { echo "Usage: $0 [-s fab]  [-o org1] [-m 7] [-c cchhlx01] [-n hhlx01bills]  [-q {\"Args\":[\"query\",\"c\"]} ]  " 1>&2; exit 1; }

while getopts ":s:o:m:c:f:i:p:n:v:e:q:r:" W; do
    case "${W}" in
        s)
            s=${OPTARG}
            ;;
        o)
            o=${OPTARG}
            ;;
		m)
            m=${OPTARG}
            ;;
		c)
            c=${OPTARG}
            ;;
		f)
            f=${OPTARG}
            ;;
		n)
            n=${OPTARG}
            ;;
		v)
            v=${OPTARG}
            ;;
		i)
            i=${OPTARG}
            ;;
		p)
            p=${OPTARG}
            ;;
		e)
            e=${OPTARG}
            ;;
		q)
            q=${OPTARG}
            ;;
		r)
            r=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

#echo "s = ${s}"
#echo "o = ${o}"
#echo "m = ${m}"

if [ -z "${s}" ] || [ -z "${o}" ] || [ -z "${m}" ]; then
    usage
fi



networkName=${s}
org=${o}
command=${m}
channelName=${c}
chainCodePath=${f}
chainCodeName=${n}
version=${v}
initContent=${i}
policy=${p}
invokeContent=${e}
queryContent=${q}
orderer=${r}

container=` kubectl get pod -n ${networkName}|grep cli-${org}|awk '{print $1}' `

if [ "1" = "$command" ];then
	getChainCodeInstalled
elif [ "2" = "$command" ];then
	if [ -z "${c}" ] ; then
      usage
	fi
	getChainCodeInstantiatd
elif [ "3" = "$command" ];then
	if  [ -z "${f}" ]; then
      usageForInstall
	fi
	installChainCode
elif [ "4" = "$command" ];then
	if [ -z "${r}" ] || [ -z "${c}" ] || [ -z "${n}" ] || [ -z "${v}" ] || [ -z "${p}" ]; then
      usageForInstantiate
	fi
	echo "channelName = ${channelName}"
	echo "version = ${version}"
	echo "chainCodeName = ${chainCodeName}"
	echo "initContent = ${initContent}"
	echo "policy = ${policy}"
	instantiateChainCode
elif [ "5" = "$command" ];then
	if [ -z "${r}" ] || [ -z "${c}" ] || [ -z "${n}" ] || [ -z "${v}" ] || [ -z "${p}" ]; then
      usageForUpgrade
	fi
	echo "channelName = ${channelName}"
	echo "version = ${version}"
	echo "chainCodeName = ${chainCodeName}"
	echo "initContent = ${initContent}"
	echo "policy = ${policy}"
	upgradeChainCode
elif [ "6" = "$command" ];then
	if [ -z "${r}" ] || [ -z "${c}" ] || [ -z "${e}" ]; then
      usageForInvoke
	fi
	invokeChainCode
elif [ "7" = "$command" ];then
	if [ -z "${c}" ] || [ -z "${q}" ]; then
      usageForQuery
	fi
	queryChainCode
fi




