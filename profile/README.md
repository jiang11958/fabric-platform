
sh run.sh "{\"cluster\":{\"name\":\"fab\"},\"org\":{\"name\":\"org1\",\"mspName\":\"org1MSP\",\"domain\":\"org1.example.com\",\"port\":\"7051\"},\"orderer\":{\"name\":\"orderer\",\"count\":\"1\",\"domain\":\"orderer.example.com\"},\"orgs\":[{\"name\":\"org1\",\"mspName\":\"org1MSP\",\"domain\":\"org1.example.com\",\"port\":\"7051\",\"count\":\"1\"},{\"name\":\"org2\",\"mspName\":\"org2MSP\",\"domain\":\"org2.example.com\",\"port\":\"7051\",\"count\":\"1\"},{\"name\":\"org3\",\"mspName\":\"org3MSP\",\"domain\":\"org3.example.com\",\"port\":\"7051\",\"count\":\"1\"}],\"channels\":[{\"name\":\"cchhlx01\",\"orgs\":[\"org1\",\"org3\"]},{\"name\":\"cczxst01\",\"orgs\":[\"org1\",\"org2\"]}]}"




{
	"cluster": {
		"name": "fab"
	},
	"org": {
		"name": "org1",
		"mspName": "org1MSP",
		"domain": "org1.example.com",
		"port": "7051"
	},
	"orderer": {
		"name": "orderer",
		"count": "1",
		"domain": "orderer.example.com"
	},
	"orgs": [{
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
	"channels": [{
		"name": "cchhlx01",
		"orgs": ["org1", "org3"]
	}, {
		"name": "cczxst01",
		"orgs": ["org1", "org2"]
	}]
}