#!/bin/bash

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "     sh run.sh fab getca-orderer.sh /mnt/fabric orderer.example.com 1 123456 hostAliasePath"
}

if [ $# -ne 7 ];
then
	printHelp
	exit 1
fi

clusterName=$1
shFile=$2
tempPath=$3
orgDomain=$4
count=$5
passWord=$6
hostAliasePath=$7

type="peer"
if [[ $shFile == *orderer* ]];then
	type="orderer"
fi


url=` kubectl get svc -n $clusterName --show-labels | grep "tlsca.$orgDomain" | awk '{split($7,dom,"="); split($5,port,/[:/]/); print dom[2]":"port[2] }' `

#wait for ca server bootup
wget --no-check-certificate --tries=60 --retry-connrefused --waitretry=100 --read-timeout=20 --timeout=15  --continue https://$url


for(( i=0;i<count;i++ ))
do
    domain="$type$i.$orgDomain"
	sh $shFile $tempPath $url $orgDomain $domain $passWord	
done	

#write helm hosts aliase file
kubectl get svc -n $clusterName -l addToHostAliases=true -o jsonpath='{"hostAliases:\n"}{range..items[*]}- ip: {.spec.clusterIP}{"\n"}  hostnames: [{.metadata.labels.domain}]{"\n"}{end}' > $hostAliasePath

exit 0
			