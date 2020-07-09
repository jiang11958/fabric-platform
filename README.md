sh run.sh "{'cluster':{'name':'fab'},'nfs':{'domain':'','in_ip':'172.21.28.224','ip':'172.21.28.224','port':22,'user':'root','pass':'kaziyuan@1231','path':'/nfs/fabric/fab','export':'172.21.28.0/24'},'orderer':{'name':'orderer','type':'solo','port':'7050','count':1,'domain':'orderer.example.com','password':'12345678','batchTimeout':'2','maxMessageCount':'10','absoluteMaxBytes':'99','preferredMaxBytes':'512'},'orgs':[{'name':'org1','mspName':'org1MSP','domain':'org1.example.com','stateDbType':'LevelDB','port':'7051','count':1},{'name':'org2','mspName':'org2MSP','domain':'org2.example.com','stateDbType':'LevelDB','port':'7051','count':1},{'name':'org3','mspName':'org3MSP','domain':'org3.example.com','stateDbType':'LevelDB','port':'7051','count':1}],'channels':[{'name':'cchhlx01','orgs':['org1','org3']},{'name':'cczxst01','orgs':['org1','org2']}]}" 



{
	"cluster": {
		"name": "fab"                      #集群名称
	},
	"nfs": {
		"domain": "",
		"in_ip": "172.21.28.225",
		"ip": "161.117.249.248",
		"port": 22,
		"user": "root",
		"pass": "kaziyuan@1231"
		"path": "/nfs/fabric/fab",	   #共享目录
		"export": "172.21.28.0/24"         #可以访问的子网
	},
	"orderer": {
		"name": "orderer",               ###必须小写字母开头
		"type": "solo",
		"port": "7050",
		"count": 1,                      #orderer个数
		"domain": "orderer.example.com",
		"password": "12345678",            #MSP证书统一密码
		"batchTimeout": "2",               #区块打包超时时间/秒
		"maxMessageCount": "10",           #区块最大交易数
		"absoluteMaxBytes": "99",          #区块相对最大字节
		"preferredMaxBytes": "512",        #区块首选最大字节
	},
	"orgs": [{                             #组织信息
		"name": "org1",                    ###必须小写字母开头
		"mspName": "org1MSP",
		"domain": "org1.example.com",
		"useCouchdb": true,
		"port": "7051",
		"count": 1                       #peer数量
	}, {
		"name": "org2",
		"mspName": "org2MSP",
		"domain": "org2.example.com",
		"useCouchdb": true,
		"port": "7051",
		"count": 1
	}, {
		"name": "org3",
		"mspName": "org3MSP",
		"domain": "org3.example.com",
		"useCouchdb": true,
		"port": "7051",
		"count": 1
	}],
	"channels": [{                         #通道信息
		"name": "cchhlx01",
		"orgs": ["org1", "org3"]
	}, {
		"name": "cczxst01",
		"orgs": ["org1", "org2"]
	}]
}