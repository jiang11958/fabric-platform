#!/bin/bash
############################################
#
# get k8s service ip and port
# by jeozey 594485991@qq.com
#
############################################

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "     sh get_all_service.sh allService.txt"
}

if [ $# -ne 1 ];
then
	printHelp
	exit 1
fi

fileName=$1
if [ -f $fileName ];then
	rm -f $fileName
fi

oldifs="$IFS"
IFS=$'\n'

result=`kubectl get svc -n fab --show-labels| grep -v CLUSTER| grep -v ca- | grep -v None | grep -v explorer- | awk '{print $3 " " $5}' `

arr=($result)

for org in ${arr[*]}
do
	IFS="$oldifs"
    #echo "org: $org"
	tmp=($org)
	ip=${tmp[0]}
	#echo "ip : $ip"
	ports=${tmp[1]}
	#echo "ports : $ports"
	port=${ports//,/ }
	for p in ${port[*]}
	do
	  p=`echo $p | awk '{split($1,port,/[:/]/); print port[2] }'`
	  echo "$ip:$p"
	  echo "$ip:$p" >> $fileName
	done
done

cat $fileName

IFS="$oldifs"


