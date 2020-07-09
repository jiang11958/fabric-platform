{{ define "peer.deployment" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $orgName := .orgName }}
{{- $orgDomainName := .orgDomainName }}
{{- $pvc := .pvc }}
{{- $hostAliases := .hostAliases }}
{{- $stateDbType := .stateDbType }}

{{- $peerID := printf "%s.%s" $name $orgDomainName }}
{{- $peerAddr := printf "%s.%s:7051" $name $orgDomainName }}
{{- /* function title is used to upper the first char of $name */}}
{{- $localMSPID :=  printf "%sMSP" $orgName }}

apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{ $namespace }}
  name:	{{ $peerID }}
spec:
  replicas: 1
  strategy: {}
  selector:
     matchLabels:
       peer-id: {{ $peerID }}
  template:
    metadata:
      creationTimestamp: null
      labels:
       app: hyperledger
       role: peer
       peer-id: {{ $peerID }}
       org: {{ $namespace }}
    spec:
      {{- if $hostAliases }}
      hostAliases:
      {{- range $i, $alias := $hostAliases }}
      - ip: {{ $alias.ip }}
        hostnames: {{ $alias.hostnames }}
      {{- end }}
      {{- end }}{{""}}
      containers:
      {{- if eq $stateDbType "CouchDB"  }}
      - name: couchdb
        image: hyperledger/fabric-couchdb:0.4.18
        ports:
         - containerPort: 5984
      {{- end }}
      - name: {{ $name }} 
        image: hyperledger/fabric-peer:1.4.4
        env:
        - name: CORE_PEER_ADDRESSAUTODETECT
          value: "true"
        - name: CORE_LEDGER_STATE_STATEDATABASE
         {{- if eq $stateDbType "CouchDB"  }}
          value: "CouchDB"
         {{- else }}
          value: "LevelDB"
         {{- end }}
        - name: CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS
          value: "localhost:5984"
        - name: CORE_VM_ENDPOINT
          value: "unix:///host/var/run/docker.sock"
        - name: CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE
          value: "bridge"
        #- name: CORE_VM_DOCKER_HOSTCONFIG_DNS
        #  value: "10.100.200.10"
        - name: FABRIC_LOGGING_SPEC
          value: "DEBUG"
        - name: CORE_PEER_TLS_ENABLED
          value: "true"
        - name: CORE_PEER_TLS_CERT_FILE
          value: "/etc/hyperledger/fabric/tls/server.crt" 
        - name: CORE_PEER_TLS_KEY_FILE
          value: "/etc/hyperledger/fabric/tls/server.key"
        - name: CORE_PEER_TLS_ROOTCERT_FILE
          value: "/etc/hyperledger/fabric/tls/ca.crt"
        - name: CORE_PEER_GOSSIP_USELEADERELECTION
          value: "true"
        - name: CORE_PEER_GOSSIP_ORGLEADER
          value: "false"
        - name: CORE_PEER_PROFILE_ENABLED
          value: "true"
        - name: CORE_PEER_ID
          value: {{ $peerID }}
        - name: CORE_PEER_ADDRESS
          value: {{ $peerAddr }}
        - name: CORE_PEER_LOCALMSPID
          value: {{ $localMSPID }}
        - name: CORE_PEER_GOSSIP_EXTERNALENDPOINT
          value: {{ $peerAddr }}
        - name: CORE_CHAINCODE_LOGGING_LEVEL
          value: "DEBUG"
        - name: GODEBUG
          value: "netdns=go"
        workingDir: /opt/gopath/src/github.com/hyperledger/fabric/peer
        ports:
         - containerPort: 7051
         - containerPort: 7052
         #- containerPort: 7053
        command: ["/bin/bash", "-c", "--"]
        args: ["sleep 5; peer node start"]
        volumeMounts:
         - mountPath: /etc/hyperledger/fabric/msp 
           name: certificate
           subPath: crypto-config/peerOrganizations/{{ $orgDomainName }}/peers/{{ $peerID }}/msp
         - mountPath: /etc/hyperledger/fabric/tls
           name: certificate
           subPath: crypto-config/peerOrganizations/{{ $orgDomainName }}/peers/{{ $peerID }}/tls
         - mountPath: /var/hyperledger/production
           name: certificate
           subPath: crypto-config/peerOrganizations/{{ $orgDomainName }}/peers/{{ $peerID }}/production
         - mountPath: /host/var/run
           name: run
      volumes:
       - name: certificate
         persistentVolumeClaim:
             claimName: {{ $pvc }}
       - name: run
         hostPath:
           path: /var/run
       

---
{{ end }}
