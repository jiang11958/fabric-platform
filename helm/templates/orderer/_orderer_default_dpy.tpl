{{ define "orderer.default.deployment" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $orgName := .orgName }}
{{- $orgDomainName := .orgDomainName}}
{{- $pvc := .pvc }}
{{- $hostAliases := .hostAliases }}

{{- /* function title is used to upper the first char of $name */}}
{{- $localMSPID :=  printf "%sMSP" $orgName }}
{{- $ordererID := printf "%s.%s" $name $orgDomainName }}
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
       orderer-id: {{ $name }}
  template:
    metadata:
      labels:
        app: hyperledger
        role: orderer
        org: {{ $namespace }}
        orderer-id: {{ $name }}
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
        image: hyperledger/fabric-orderer:1.4.4
        env:
        - name: ORDERER_GENERAL_LOGLEVEL
          value: debug
        - name: ORDERER_GENERAL_LISTENADDRESS
          value: 0.0.0.0
        - name: ORDERER_GENERAL_GENESISMETHOD
          value: file
        - name: ORDERER_GENERAL_GENESISFILE
          value: /var/hyperledger/orderer/orderer.genesis.block
        - name: ORDERER_GENERAL_LOCALMSPID
          value: {{ $localMSPID }}
        - name: ORDERER_GENERAL_LOCALMSPDIR
          value: /var/hyperledger/orderer/msp
        - name: ORDERER_GENERAL_TLS_ENABLED
          value: "true"
        - name: ORDERER_GENERAL_TLS_PRIVATEKEY
          value: /var/hyperledger/orderer/tls/server.key
        - name: ORDERER_GENERAL_TLS_CERTIFICATE
          value: /var/hyperledger/orderer/tls/server.crt
        - name: ORDERER_GENERAL_TLS_ROOTCAS
          value: '[/var/hyperledger/orderer/tls/ca.crt]'
        - name: ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE
          value: /var/hyperledger/orderer/tls/server.crt
        - name: ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY
          value: /var/hyperledger/orderer/tls/server.key
        - name: ORDERER_GENERAL_CLUSTER_ROOTCAS
          value: '[/var/hyperledger/orderer/tls/ca.crt]'
        - name: GODEBUG
          value: "netdns=go"
        workingDir: /opt/gopath/src/github.com/hyperledger/fabric/peer
        ports:
         - containerPort: 7050
        command: ["orderer"]
        volumeMounts:
         - mountPath: /var/hyperledger/orderer/msp 
           name: certificate
           subPath: crypto-config/ordererOrganizations/{{ $orgDomainName }}/orderers/{{ $ordererID }}/msp
         - mountPath: /var/hyperledger/orderer/tls
           name: certificate
           subPath: crypto-config/ordererOrganizations/{{ $orgDomainName }}/orderers/{{ $ordererID }}/tls
         - mountPath: /var/hyperledger/orderer/orderer.genesis.block
           name: certificate
           subPath: channel-artifacts/genesis.block
         - mountPath: /var/hyperledger/production
           name: certificate
           subPath: crypto-config/ordererOrganizations/{{ $orgDomainName }}/orderers/{{ $ordererID }}/production
      volumes:
       - name: certificate
         persistentVolumeClaim:
             claimName: {{ $pvc }}

---

{{ end }}
