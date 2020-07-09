#!/bin/bash

# scripts 目录上一级目录
SDIR=$(
	# cd  "$(dirname "$0")"
	pwd
)

export PATH=$PATH:$SDIR/bin
echo "PATH: $PATH"

TLS_CA_DIR=$SDIR/ca
CA_DIR=$SDIR/fabric-ca-files
ORDERER_DIR=$SDIR/crypto-config/ordererOrganizations


# Copy the org's admin cert into some target MSP directory
# This is only required if ADMINCERTS is enabled.
function copyAdminCert() {
	set +e
	if [ $# -ne 3 ]; then
		fatal "Usage: copyAdminCert <adminCertDir> <targetMSPDIR>"
	fi
	if $ADMINCERTS; then
		dstDir=$2/admincerts
		mkdir -p $dstDir

		cp $1/signcerts/* $dstDir/$3
	fi
	set -e
}

function copyServerTls() {
	set +e
	if [ $# -ne 1 ]; then
		fatal "Usage: copyTls <targetMSPDIR>"
	fi
	
	
	cp $1/keystore/* $1/server.key
	cp $1/signcerts/* $1/server.crt
	cp $1/tlscacerts/* $1/ca.crt
	set -e
}

function copyClientTls() {
	set +e
	if [ $# -ne 1 ]; then
		fatal "Usage: copyTls <targetMSPDIR>"
	fi
	
	
	cp $1/keystore/* $1/client.key
	cp $1/signcerts/* $1/client.crt
	cp $1/tlscacerts/* $1/ca.crt
	set -e
}

function copytlsCaCerts(){
	set +e
	if [ $# -ne 3 ]; then
		fatal "Usage: copyAdminCert <tlscaCertDir> <targetMSPDIR>"
	fi
	if $ADMINCERTS; then
		dstDir=$2/tlscacerts
		mkdir -p $dstDir
		
		ls $1/tlscacerts/
		
		cp $1/tlscacerts/* $dstDir/$3
	fi
	set -e
}

function rmMSP(){
	# delete example.com/msp unnecessary files
	if [ $2 == 1 ]; then
		rm $1/keystore $1/signcerts $1/user $1/IssuerPublicKey $1/IssuerRevocationPublicKey -rf
	fi

	# delete example.com/users,orderers/msp unnecessary files
	if [ $2 == 2 ]; then
		rm $1/user $1/IssuerPublicKey $1/IssuerRevocationPublicKey -rf
	fi

}

function rmTLS(){
	rm $1/cacerts $1/keystore $1/signcerts $1/tlscacerts $1/user $1/IssuerPublicKey $1/IssuerRevocationPublicKey -rf
}

function reName(){
	set +e
	if [ $# -ne 3 ]; then
		fatal "Usage: copyAdminCert <tlscaCertDir> <targetMSPDIR>"
	fi
	
	if [ $3 == 1 ]; then
	    echo "##reName 1 ##"
		ls $1/cacerts/
		mv $1/cacerts/* $1/cacerts/$2
	fi

	if [ $3 == 2 ]; then
	    echo "##reName 1 ##"
		ls $1/cacerts/
		echo "##reName 2 ##"
		ls $1/echo "##reName 1 ##"
		ls $1/cacerts/
		
		mv $1/cacerts/* $1/cacerts/$2
		mv $1/signcerts/* $1/signcerts/$2
	fi
	set -e
}


function touchConfig(){
	echo "==============touchConfig====START==="	
	
	if [ ! -f $ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml ];then
		touch $ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml	

		echo "NodeOUs:"&>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  Enable: true"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  ClientOUIdentifier:"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    Certificate: cacerts/ca.${ORG_DOMAIN}-cert.pem"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    OrganizationalUnitIdentifier: client"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  PeerOUIdentifier:"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    Certificate: cacerts/ca.${ORG_DOMAIN}-cert.pem"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    OrganizationalUnitIdentifier: peer"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  AdminOUIdentifier:"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    Certificate: cacerts/ca.${ORG_DOMAIN}-cert.pem"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    OrganizationalUnitIdentifier: admin"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  OrdererOUIdentifier:"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    Certificate: cacerts/ca.${ORG_DOMAIN}-cert.pem"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    OrganizationalUnitIdentifier: orderer"&>>$ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml
		
	fi
	
	cp $ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp/config.yaml
	cp $ORDERER_DIR/${ORG_DOMAIN}/msp/config.yaml $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp/config.yaml
	
	echo "==============touchConfig====END==="
}
	
function addOrg() {
	echo "==============Add affiliation START ======="
	set +e
	fabric-ca-client affiliation list
	fabric-ca-client affiliation remove --force org1
	fabric-ca-client affiliation remove --force org2
	

	array=(${AFFILIATION//./ })  
 
	temp=""
	for var in ${array[@]}
	do
	   if [ "${temp}" == "" ]; then
		 temp=$var	   
	   else
		 temp=$temp'.'$var
	   fi
	   
	   echo $temp
	   fabric-ca-client affiliation add $temp	   
	   
	done 
	
	set -e
	echo "==============Add affiliation END ======="
}

# generate certs for orderer  orderer.example.com and Admin@example.com 
function generateOrdererMSP() {



	echo "==============init-ordererCA-Admin====START==="
	export FABRIC_CA_CLIENT_HOME=$CA_DIR/${ORG_DOMAIN}_CA_Admin
	
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${NFS}/resources/fabric-ca-server/${ORG_DOMAIN}/ca-cert.pem
	fabric-ca-client enroll -u https://admin:adminpw@$URLtls --csr.cn Admin@${ORG_DOMAIN}  --csr.hosts Admin@${ORG_DOMAIN}
	echo "==============init-${ORG_DOMAIN} CA-Admin====END==="

	addOrg # add affiliation
	
	echo "==============orderer-Register====START==="
	#sleep 1
	fabric-ca-client register --id.name $OrdererName --id.secret $OrdererPw --id.type orderer --id.affiliation $AFFILIATION
	echo "==============orderer-Register====END==="	
	
	echo "==============orderer-enroll====START==="
	fabric-ca-client enroll -u https://$OrdererName:$OrdererPw@$URLtls --csr.cn ${DOMAIN}  --csr.hosts ${DOMAIN} -M $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp --id.affiliation $AFFILIATION
	echo "==============orderer-enroll====END==="
	
	
	if [ ! -f $ORDERER_DIR/${ORG_DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem ] ; then
		echo "==============orderer-getcacert====START==="
		fabric-ca-client getcacert -u https://$URLtls -M $ORDERER_DIR/${ORG_DOMAIN}/msp --id.type client --id.affiliation $AFFILIATION
		echo "==============orderer-getcacert====END==="
	fi
	

	if [ ! -d $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp ] ; then
		echo "==============orderer-Register-Admin====START==="
		set +e
		# fabric-ca-client register --id.secret Admin.example.compw --id.name Admin@example.com --id.type client --id.affiliation com.example --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert'
		fabric-ca-client register -u https://admin:adminpw@$URLtls  --id.name $AdminName --id.secret $AdminPw --id.type client --id.affiliation $AFFILIATION --id.attrs admin=true:ecert
		set -e
		echo "==============orderer-Register-Admin====END==="	
	
		echo "==============orderer-enroll-Admin====START==="
	
		export FABRIC_CA_CLIENT_HOME=$ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName
		fabric-ca-client enroll -u https://$AdminName:$AdminPw@$URLtls --csr.cn $AdminName  --csr.hosts $AdminName --id.affiliation $AFFILIATION
		
		rm $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/fabric-ca-client-config.yaml
	
		echo "==============orderer-enroll-Admin====END==="	
	fi
	
	# copy admin cert to each MSP admincerts directory
	echo "==============orderer-copy-admincerts====START==="
	if [ ! -f $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp/admincerts/$AdminName-cert.pem ] ; then
		# copy to Orderer
		copyAdminCert $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp $ORDERER_DIR/${ORG_DOMAIN}/msp $AdminName-cert.pem
		# copy to users/Admin@example.com 
		copyAdminCert $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp $AdminName-cert.pem
	fi
	# copy to orderers/${ORG_DOMAIN} 
	copyAdminCert $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp $AdminName-cert.pem
	echo "==============orderer-copy-admincerts====END==="
	
	echo "==============orderer-rm-msp-unimportant-file====START==="
	rmMSP $ORDERER_DIR/${ORG_DOMAIN}/msp 1

	rmMSP $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp 2
	rmMSP $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp 2
	echo "==============orderer-rm-msp-unimportant-file====END==="
	
	echo "==============orderer-rename-msp-some-file====START==="
	

	if [ ! -f $ORDERER_DIR/${ORG_DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem ] ; then
		mv $ORDERER_DIR/${ORG_DOMAIN}/msp/cacerts/*  $ORDERER_DIR/${ORG_DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem 	
	fi
	
	if [ ! -f $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem ] ; then
		mv $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp/cacerts/* $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem 
	fi
	
	if [ ! -f $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp/signcerts/${DOMAIN}-cert.pem ] ; then
		mv $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp/signcerts/* $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp/signcerts/${DOMAIN}-cert.pem
	fi
	
	if [ ! -f $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem ] ; then
		mv $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp/cacerts/* $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem
	fi
	
	if [ ! -f $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp/signcerts/$AdminName-cert.pem ] ; then
		mv $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp/signcerts/* $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp/signcerts/$AdminName-cert.pem
	fi
	echo "==============orderer-rename-msp-some-file====END==="
}

# generate tls certs for orderer  orderer.example.com and Admin@example.com 
function generateOrdererTLS() {
	
	echo "==============init-tlsCA-Admin====START==="
	export FABRIC_CA_CLIENT_HOME=$CA_DIR/TLS_${DOMAIN}_CA_Admin

	# TLS CERTFILES
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${NFS}/resources/fabric-ca-server/${ORG_DOMAIN}/ca-cert.pem
	fabric-ca-client enroll -u https://admin:adminpw@$URLtls --csr.cn Admin@tlsca.example.com  --csr.hosts Admin@tlsca.example.com
	echo "==============init-tlsCA-Admin====END==="
	
	
	
	echo "==============orderer-tls-enroll====START==="
	# enroll tls certs for orderer.example.com and Admin@example.com
	fabric-ca-client enroll --enrollment.profile tls -u https://$OrdererName:$OrdererPw@$URLtls -M $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/tls --csr.cn=${DOMAIN} --csr.hosts=${DOMAIN} --csr.hosts=orderer --id.affiliation $AFFILIATION
	fabric-ca-client enroll --enrollment.profile tls -u https://$AdminName:$AdminPw@$URLtls -M $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/tls --id.affiliation $AFFILIATION
	echo "==============orderer-tls-enroll====END==="

	echo "==============orderer-copy-tlscacerts====START==="
	# example.com/msp/tlscacerts
	copytlsCaCerts $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/tls $ORDERER_DIR/${ORG_DOMAIN}/msp tlsca.${ORG_DOMAIN}-cert.pem
	# example.com/orderers/orderer.example.com/msp/tlscacerts
	copytlsCaCerts $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/tls $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/msp tlsca.${ORG_DOMAIN}-cert.pem
	# example.com/users/Admin@example.com/msp/tlscacerts
	copytlsCaCerts $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/tls $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/msp tlsca.${ORG_DOMAIN}-cert.pem
	
	echo "==============orderer-copy-tlscacerts====END==="


	copyServerTls $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/tls

	copyClientTls $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/tls

	echo "==============orderer-rm-tls-unimportant-file====START==="
	rmTLS $ORDERER_DIR/${ORG_DOMAIN}/orderers/${DOMAIN}/tls
	rmTLS $ORDERER_DIR/${ORG_DOMAIN}/users/$AdminName/tls
	echo "==============orderer-rm-tls-unimportant-file====END==="
}


function setAffiliation(){
	domain=$1

	t=${domain//./ };
	arr=($t);

	str='' 
	length=${#arr[*]}

	for(( i=$((length-1));i>=0;i--))
	do 
		if [ $i == $((length-1)) ];then				
			str=$str${arr[i]}
		else
			str="$str.${arr[i]}"				
		fi
	done 
	AFFILIATION=$str
	echo $AFFILIATION

}


function makeCAControl() {
	echo "######################################################################"
	echo "#---------------------get CA with CA Servet start--------------------#"
	echo "######################################################################"
	
	echo $DOMAIN
	#clearPath
	generateOrdererMSP
	generateOrdererTLS
	#touchConfig

	echo "######################################################################"
	echo "#---------------------get CA with CA Server END----------------------#"
	echo "######################################################################"
}

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "     sh getca-orderer.sh nfsPath caUrl orgDomain ordererDomain passWord"
}


if [ $# -ne 5 ];
then
	printHelp
	exit 1
fi

NFS=$1
URLtls=$2
ORG_DOMAIN=$3

setAffiliation $ORG_DOMAIN

DOMAIN=$4
PASSWORD=$5

OrdererName=${DOMAIN}
OrdererPw=$PASSWORD

AdminName=Admin@${ORG_DOMAIN}
AdminPw=$PASSWORD

sleep 1

makeCAControl

exit 0
