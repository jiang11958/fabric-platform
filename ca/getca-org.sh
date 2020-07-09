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
PEER_ORG_DIR=$SDIR/crypto-config/peerOrganizations



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
	
	if [ ! -f $PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml ];then
		touch $PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml	

		echo "NodeOUs:"&>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  Enable: true"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  ClientOUIdentifier:"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    Certificate: cacerts/ca.${ORG_DOMAIN}-cert.pem"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    OrganizationalUnitIdentifier: client"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  PeerOUIdentifier:"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    Certificate: cacerts/ca.${ORG_DOMAIN}-cert.pem"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    OrganizationalUnitIdentifier: peer"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  AdminOUIdentifier:"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    Certificate: cacerts/ca.${ORG_DOMAIN}-cert.pem"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    OrganizationalUnitIdentifier: admin"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "  OrdererOUIdentifier:"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    Certificate: cacerts/ca.${ORG_DOMAIN}-cert.pem"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
		echo "    OrganizationalUnitIdentifier: orderer"&>>$PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml
	fi
	
	cp $PEER_ORG_DIR/${ORG_DOMAIN}/msp/config.yaml $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp/config.yaml
	
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



function generateOrgMSP() {


	echo "==============init-${ORG_DOMAIN} CA-Admin====START==="
	export FABRIC_CA_CLIENT_HOME=$CA_DIR/${ORG_DOMAIN}_CA_Admin

	export FABRIC_CA_CLIENT_TLS_CERTFILES=${NFS}/resources/fabric-ca-server/${ORG_DOMAIN}/ca-cert.pem
	fabric-ca-client enroll -u https://admin:adminpw@$URLtls --csr.cn Admin@${ORG_DOMAIN}  --csr.hosts Admin@${ORG_DOMAIN}
	echo "==============init-${ORG_DOMAIN} CA-Admin====END==="
	
	addOrg # add affiliation
	

	echo "============${DOMAIN} Register====START==="
	set +e
	fabric-ca-client register  --id.name $PeerName --id.secret $PeerPw --id.type peer --id.affiliation $AFFILIATION
	set -e
	echo "============${DOMAIN} Register====END==="
	
	echo "==============${DOMAIN} Enroll====START==="
	fabric-ca-client enroll -u https://$PeerName:$PeerPw@$URLtls --csr.cn ${DOMAIN}  --csr.hosts ${DOMAIN} -M $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp --id.affiliation $AFFILIATION
	echo "==============${DOMAIN} Enroll====END==="
	
	if [ ! -f $PEER_ORG_DIR/${ORG_DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem ] ; then
		echo "==============${DOMAIN} getcacert====START==="
		fabric-ca-client getcacert -u https://$URLtls -M $PEER_ORG_DIR/${ORG_DOMAIN}/msp --id.type client --id.affiliation $AFFILIATION
		echo "==============${DOMAIN} getcacert====END==="
	fi

	if [ ! -d $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp ] ; then
		echo "==============${DOMAIN} Register-Admin ====START==="
		set +e
		# fabric-ca-client register --id.name $AdminName --id.secret $AdminNamepw --id.type client --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.affiliation $AFFILIATION
		fabric-ca-client register  --id.name $AdminName --id.secret $AdminPw --id.type client --id.attrs admin=true:ecert --id.affiliation $AFFILIATION
		set -e
		echo "==============${DOMAIN} Register-Admin 1====END==="	
		
		echo "==============${DOMAIN} enroll-Admin====START==="
		export FABRIC_CA_CLIENT_HOME=$PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName
		fabric-ca-client enroll -u https://$AdminName:$AdminPw@$URLtls --csr.cn $AdminName  --csr.hosts $AdminName --id.affiliation $AFFILIATION
		rm $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/fabric-ca-client-config.yaml
		echo "==============${DOMAIN} enroll-Admin====END==="	
	fi
	
	
	# copy admin cert to each MSP admincerts directory
	echo "==============${DOMAIN} copy-admincerts====START==="
	copyAdminCert $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp $PEER_ORG_DIR/${ORG_DOMAIN}/msp $AdminName-cert.pem
	copyAdminCert $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp $PEER_ORG_DIR/${ORG_DOMAIN}/peers/$PeerName/msp $AdminName-cert.pem
	copyAdminCert $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp $AdminName-cert.pem
	echo "==============${DOMAIN} copy-admincerts====END==="

	echo "==============org-rm-msp-unimportant-file====START==="
	rmMSP $PEER_ORG_DIR/${ORG_DOMAIN}/msp 1

	rmMSP $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp 2

	rmMSP $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp 2
	echo "==============org-rm-msp-unimportant-file====END==="

	echo "==============org-rename-msp-some-file====START==="
	if [ ! -f $PEER_ORG_DIR/${ORG_DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem ] ; then
		mv $PEER_ORG_DIR/${ORG_DOMAIN}/msp/cacerts/*  $PEER_ORG_DIR/${ORG_DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem 	
	fi
	
	if [ ! -f $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem  ] ; then
		mv $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp/cacerts/* $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem 
	fi
	
	if [ ! -f $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp/signcerts/${DOMAIN}-cert.pem ] ; then
		mv $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp/signcerts/* $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp/signcerts/${DOMAIN}-cert.pem
	fi
	
	if [ ! -f $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem ] ; then
		mv $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp/cacerts/* $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp/cacerts/ca.${ORG_DOMAIN}-cert.pem
	fi
	
	if [ ! -f $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp/signcerts/$AdminName-cert.pem ] ; then
		mv $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp/signcerts/* $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp/signcerts/$AdminName-cert.pem
	fi
	set -e
	echo "==============org-rm-msp-unimportant-file====END==="
		
}


 
function generateOrgTLS() {

	echo "==============init-tls${org}CA-Admin====START2==="
	export FABRIC_CA_CLIENT_HOME=$CA_DIR/TLS_${DOMAIN}_CA_Admin
			
	export FABRIC_CA_CLIENT_TLS_CERTFILES=${NFS}/resources/fabric-ca-server/${ORG_DOMAIN}/ca-cert.pem
	fabric-ca-client enroll -u https://admin:adminpw@$URLtls --csr.cn Admin@tlsca.${ORG_DOMAIN}  --csr.hosts Admin@tlsca.${ORG_DOMAIN}
	echo "==============init-tls${org}CA-Admin====END==="


	echo "==============$org-tls-enroll====START==="
	fabric-ca-client enroll --enrollment.profile tls -u https://$PeerName:$PeerPw@$URLtls -M $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/tls --csr.cn=${DOMAIN} --csr.hosts=${DOMAIN} --id.affiliation $AFFILIATION

	fabric-ca-client enroll --enrollment.profile tls -u https://$AdminName:$AdminPw@$URLtls -M $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/tls --id.affiliation $AFFILIATION
	echo "==============$org-tls-enroll====END==="

	echo "==============$org-copy-tlscacerts====START==="
	# ${ORG_DOMAIN}/msp/tlscacerts
	copytlsCaCerts $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/tls $PEER_ORG_DIR/${ORG_DOMAIN}/msp tlsca.${ORG_DOMAIN}-cert.pem
	# ${ORG_DOMAIN}/peers/peer0,peer1.example.com/msp/tlscacerts
	copytlsCaCerts $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/tls $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/msp tlsca.${ORG_DOMAIN}-cert.pem
	# ${ORG_DOMAIN}/users/Admin,User1@example.com/msp/tlscacerts
	copytlsCaCerts $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/tls $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/msp tlsca.${ORG_DOMAIN}-cert.pem
	echo "==============$org-copy-tlscacerts====END==="


	copyServerTls $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/tls
	
	copyClientTls $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/tls

	echo "==============org-rm-tls-unimportant-file====START==="
	rmTLS $PEER_ORG_DIR/${ORG_DOMAIN}/peers/${DOMAIN}/tls

	rmTLS $PEER_ORG_DIR/${ORG_DOMAIN}/users/$AdminName/tls
	echo "==============org-rm-tls-unimportant-file====END==="

	
}



function makeCAControl() {

	echo "######################################################################"
	echo "#---------------------get CA with CA Servet start--------------------#"
	echo "######################################################################"
	#clearPath
	generateOrgMSP
	generateOrgTLS
	touchConfig

	echo "######################################################################"
	echo "#---------------------get CA with CA Server END----------------------#"
	echo "######################################################################"
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

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "     sh getca-org.sh nfsPath caUrl orgDomain affiliation peerDomain passWord"
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
	
PeerName=${DOMAIN}
PeerPw=$PASSWORD
AdminName=Admin@${ORG_DOMAIN}
AdminPw=$PASSWORD

	
makeCAControl

exit 0
