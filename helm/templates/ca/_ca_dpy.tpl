{{ define "ca.deployment" }}

{{- $namespace := .namespace }}
{{- $orgDomainName := .orgDomainName }}
{{- $name := .name }}
{{- $pvc := .pvc }}

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
      role: ca
      org: {{ $orgDomainName }}
      name: ca
  template:
    metadata:
      labels:
       app: hyperledger
       role: ca
       org: {{ $orgDomainName }}
       name: ca
    spec:
     containers:
       - name: ca
         image: hyperledger/fabric-ca:1.4.6
         env: 
         - name:  FABRIC_CA_HOME
           value: /etc/hyperledger/fabric-ca-server
         - name:  FABRIC_CA_SERVER_CA_NAME
           value: tlsca.{{ $orgDomainName }}
         - name:  FABRIC_CA_SERVER_TLS_ENABLED
           value: "true"
         ports:
          - containerPort: 7054
         command: ["sh"]
         args:  ["-c", " fabric-ca-server start -b admin:adminpw --csr.cn tlsca.{{ $orgDomainName }} --csr.hosts tlsca.{{ $orgDomainName }} --cfg.affiliations.allowremove  --cfg.identities.allowremove -d "]
         volumeMounts:
          - mountPath: /etc/hyperledger/fabric-ca-server-config
            name: certificate
            subPath: ca/{{ $orgDomainName }}/
          - mountPath: /etc/hyperledger/fabric-ca-server
            name: certificate
            subPath: fabric-ca-server/{{ $orgDomainName }}/
     volumes:
       - name: certificate
         persistentVolumeClaim:
             claimName: {{ $pvc }} 

--- 
{{ end }}
