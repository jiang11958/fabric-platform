```
sh run.sh "{\"network\":{\"name\":\"fab\"},\"org\":{\"name\":\"org1\",\"mspName\":\"org1MSP\",\"domain\":\"org1.example.com\",\"port\":\"7051\"},\"orderer\":{\"name\":\"orderer\",\"count\":\"1\",\"domain\":\"orderer.example.com\"},\"orgs\":[{\"name\":\"org1\",\"mspName\":\"org1MSP\",\"domain\":\"org1.example.com\",\"port\":\"7051\",\"count\":\"1\"},{\"name\":\"org2\",\"mspName\":\"org2MSP\",\"domain\":\"org2.example.com\",\"port\":\"7051\",\"count\":\"1\"},{\"name\":\"org3\",\"mspName\":\"org3MSP\",\"domain\":\"org3.example.com\",\"port\":\"7051\",\"count\":\"1\"}],\"channels\":[{\"name\":\"mychannel2\",\"orgs\":[\"org1\",\"org3\"]},{\"name\":\"mychannel1\",\"orgs\":[\"org1\",\"org2\"]}]}"
```


```
{
	"network": {                           #name of this fabric network
		"name": "fab"
	},
	"org": {                               #org info for this connection profile
		"name": "org1",
		"mspName": "org1MSP",
		"domain": "org1.example.com",
		"port": "7051"
	},
	"orderer": {                           #orderer org setting
		"name": "orderer",
		"count": "5",                      #solo:1 kafka:3 etcdRaft:5
		"domain": "orderer.example.com"
	},
	"orgs": [{                             #all orgs setting
		"name": "org1",
		"mspName": "org1MSP",
		"domain": "org1.example.com",
		"port": "7051",
		"count": "1"
	}, {
		"name": "org2",
		"mspName": "org2MSP",
		"domain": "org2.example.com",
		"port": "7051",
		"count": "1"
	}, {
		"name": "org3",
		"mspName": "org3MSP",
		"domain": "org3.example.com",
		"port": "7051",
		"count": "1"
	}],
	"channels": [{                        #all channels setting
		"name": "mychannel2",
		"orgs": ["org1", "org3"]
	}, {
		"name": "mychannel1",
		"orgs": ["org1", "org2"]
	}]
}
```