{{ define "cli.deployment" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $orgName := .orgName }}
{{- $orgDomainName := .orgDomainName }}
{{- $sharedPVC := .sharedPVC }}
{{- $cliPVC := .cliPVC }}
{{- $hostAliases := .hostAliases }}

{{- /* function title is used to upper the first char of $name */}}
{{- $localMSPID :=  printf "%sMSP" $orgName }}
{{- $peerAddr := printf "peer0.%s:7051" $orgDomainName }}

apiVersion: apps/v1
kind: Deployment
metadata:
   namespace: {{ $namespace }}
   name: {{ $name }}
spec:
  replicas: 1
  strategy: {}
  selector:
    matchLabels:
      app: cli
  template:
    metadata:
      labels:
       app: cli
    spec:
	  {{- if $hostAliases }}
      hostAliases:
      {{- range $i, $alias := $hostAliases }}
      - ip: {{ $alias.ip }}
        hostnames: {{ $alias.hostnames }}
      {{- end }}
      {{- end }}{{""}}
      containers:
        - name: {{ $name }}
          image:  hyperledger/fabric-tools:1.4.4
          env:
          - name: CORE_PEER_TLS_ENABLED
            value: "true"
          - name: CORE_PEER_TLS_CERT_FILE
            value: /etc/hyperledger/fabric/tls/server.crt
          - name: CORE_PEER_TLS_KEY_FILE
            value: /etc/hyperledger/fabric/tls/server.key
          - name: CORE_PEER_TLS_ROOTCERT_FILE
            value: /etc/hyperledger/fabric/tls/ca.crt
          - name: CORE_VM_ENDPOINT
            value: unix:///host/var/run/docker.sock
          - name: GOPATH
            value: /opt/gopath
          - name: FABRIC_LOGGING_SPEC
            value: DEBUG
          - name: CORE_PEER_ID
            value: {{ $name }}
          - name: CORE_PEER_ADDRESS
            value: {{ $peerAddr }}
          - name: CORE_PEER_LOCALMSPID
            value: {{ $localMSPID }}
          - name: CORE_PEER_MSPCONFIGPATH
            value: /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/{{ $orgDomainName }}/users/Admin@{{ $orgDomainName }}/msp
          workingDir: /opt/gopath/src/github.com/hyperledger/fabric/peer
          command: [ "/bin/bash", "-c", "--" ]
          args: [ "while true; do sleep 30; done;" ]
          volumeMounts:
           - mountPath: /host/var/run/
             name: run
          # when enable tls , should mount orderer tls ca
           - mountPath: /etc/hyperledger/fabric/msp
             name: certificate
             subPath: crypto-config/peerOrganizations/{{ $orgDomainName }}/users/Admin@{{ $orgDomainName }}/msp
           - mountPath: /etc/hyperledger/fabric/tls
             name: certificate
             subPath: crypto-config/peerOrganizations/{{ $orgDomainName }}/users/Admin@{{ $orgDomainName }}/tls
           - mountPath: /opt/gopath/src/github.com/hyperledger/fabric/peer/resources/chaincodes
             name: resources
             subPath: chaincodes
           - mountPath: /opt/gopath/src/github.com/hyperledger/fabric/peer/resources/channel-artifacts
             name: resources
             subPath: channel-artifacts
           - mountPath: /opt/gopath/src/github.com/hyperledger/fabric/peer/resources/scripts
             name: resources
             subPath: scripts
           - mountPath: /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations
             name: resources
             subPath: crypto-config/ordererOrganizations
           - mountPath: /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations
             name: resources
             subPath: crypto-config/peerOrganizations
      volumes:
        - name: certificate
          persistentVolumeClaim:
              claimName: {{ $sharedPVC }}
        - name: resources
          persistentVolumeClaim:
              claimName: {{ $cliPVC }}
        - name: run
          hostPath:
            path: /var/run 

---
{{ end }}
