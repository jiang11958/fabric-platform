## Introduce

* a tool to build a hyperledger fabric network in k8s.
* support multi orderer type: solo,kafka,etcdRaft
* support peer state database type: LevelDB and CouchDB
* support fabric-ca server to manager the MSP identity
* support blockchain-explorer in each org
* support generate connection profile setting file conveniently

## How To Use
#### 1.we need a kubernetes network
[how to bootup a k8s network](https://github.com/jiang11958/k8s-bootup)

#### 2.start the fabric network
```
#exec the commands below on your k8s master host
cd ~
git clone https://github.com/jiang11958/fabric-platform
cd ~/fabric-platform
sh run.sh "{'network':{'name':'fab'},'nfs':{'domain':'','in_ip':'172.21.28.224','ip':'172.21.28.224','port':22,'user':'root','pass':'password','path':'/nfs/fabric/fab','export':'172.21.28.0/24'},'orderer':{'name':'orderer','type':'etcdRaft','count':5,'port':'7050','domain':'orderer.example.com','password':'12345678','batchTimeout':'2','maxMessageCount':'10','absoluteMaxBytes':'99','preferredMaxBytes':'512'},'orgs':[{'name':'org1','mspName':'org1MSP','domain':'org1.example.com','stateDbType':'LevelDB','port':'7051','count':1},{'name':'org2','mspName':'org2MSP','domain':'org2.example.com','stateDbType':'LevelDB','port':'7051','count':1},{'name':'org3','mspName':'org3MSP','domain':'org3.example.com','stateDbType':'LevelDB','port':'7051','count':1}],'channels':[{'name':'mychannel2','orgs':['org1','org3']},{'name':'mychannel1','orgs':['org1','org2']}]}" 
```

```
{
	"network": {
		"name": "fab"                      #name of this fabric network
	},
	"nfs": {                               #nfs setting
		"domain": "",
		"in_ip": "172.21.28.225",          #lan ip
		"ip": "161.117.249.248",           #internet ip
		"port": 22,                        #ssh port
		"user": "root",                    #ssh user
		"pass": "password"                 #ssh password
		"path": "/nfs/fabric/fab",	       #nfs share directory
		"export": "172.21.28.0/24"         #nfs sub net
	},
	"orderer": {
		"name": "orderer",                 #must start with lower case character
		"type": "etcdRaft",                    #solo kafka etcdRaft
		"port": "7050",
		"count": 5,                        #solo:1 kafka:3 etcdRaft:5
		"domain": "orderer.example.com",   #orderer org domain
		"password": "12345678",            #MSP cert password
		"batchTimeout": "2",               #orderer setting,default value
		"maxMessageCount": "10",           #orderer setting,default value
		"absoluteMaxBytes": "99",          #orderer setting,default value
		"preferredMaxBytes": "512",        #orderer setting,default value
	},
	"orgs": [{                             #org setting
		"name": "org1",                    #must start with lower case character
		"mspName": "org1MSP",              #MSP ID
		"domain": "org1.example.com",      #org domain
		"stateDbType": "LevelDB",          #LevelDB or CouchDB
		"port": "7051",                    #peer port
		"count": 1                         #peer count
	}, {
		"name": "org2",
		"mspName": "org2MSP",
		"domain": "org2.example.com",
		"stateDbType": "LevelDB",          
		"port": "7051",
		"count": 1
	}, {
		"name": "org3",
		"mspName": "org3MSP",
		"domain": "org3.example.com",
		"stateDbType": "LevelDB",
		"port": "7051",
		"count": 1
	}],
	"channels": [{                         #channel setting
		"name": "mychannel2",                #channel name
		"orgs": ["org1", "org3"]           #org name in channel
	}, {
		"name": "mychannel1",
		"orgs": ["org1", "org2"]
	}]
}
```
#### 3.generate connection profile
[JUMP TO THE README](https://github.com/jiang11958/fabric-platform/tree/master/profile)
```
cd ~/fabric-platform/profile
sh run.sh "{\"network\":{\"name\":\"fab\"},\"org\":{\"name\":\"org1\",\"mspName\":\"org1MSP\",\"domain\":\"org1.example.com\",\"port\":\"7051\"},\"orderer\":{\"name\":\"orderer\",\"count\":\"1\",\"domain\":\"orderer.example.com\"},\"orgs\":[{\"name\":\"org1\",\"mspName\":\"org1MSP\",\"domain\":\"org1.example.com\",\"port\":\"7051\",\"count\":\"1\"},{\"name\":\"org2\",\"mspName\":\"org2MSP\",\"domain\":\"org2.example.com\",\"port\":\"7051\",\"count\":\"1\"},{\"name\":\"org3\",\"mspName\":\"org3MSP\",\"domain\":\"org3.example.com\",\"port\":\"7051\",\"count\":\"1\"}],\"channels\":[{\"name\":\"mychannel2\",\"orgs\":[\"org1\",\"org3\"]},{\"name\":\"mychannel1\",\"orgs\":[\"org1\",\"org2\"]}]}" 
```

#### 4.show blockchain-explorer
```
[root@test ~]cd ~
[root@test ~]kubectl get svc -n fab | grep explorer | awk '{split($5,port,/[:/]/); print $1 " " port[2]}'
# get the explorer internet port
#  explorer-org1 32320        ,so your org1 explorer url: http://your_master_ip:32320
#  explorer-org2 31224        ,so your org2 explorer url: http://your_master_ip:31224
#  explorer-org3 32101        ,so your org3 explorer url: http://your_master_ip:32101
```

#### 5.remove the fabric network 
```
cd ~/fabric-platform
sh remove.sh "{'network':{'name':'fab'}}"
```

## TODO LIST

* add org dynamically 
* remove org dynamically 
* create channel dynamically 
* join channel dynamically 
* exit channel dynamically 