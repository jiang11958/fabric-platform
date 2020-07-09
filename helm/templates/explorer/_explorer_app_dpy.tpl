{{ define "explorer.app.deployment" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $dbHostName := .dbHostName }}
{{- $orgName := .orgName }}
{{- $orgDomainName := .orgDomainName }}
{{- $pvc := .pvc }}
{{- $hostAliases := .hostAliases }}


apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{ $namespace }}
  name: {{ $name }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app-id: {{ $name }}
  template:
    metadata:
      labels:
        app-id: {{ $name }}
    spec:
      {{- if $hostAliases }}
      hostAliases:
      {{- range $i, $alias := $hostAliases }}
      - ip: {{ $alias.ip }}
        hostnames: {{ $alias.hostnames }}
      {{- end }}
      {{- end }}{{""}}

      containers:
      - name: explorer
        image: hyperledger/explorer:latest
        command: ["sh" , "-c" , "/fabric/config/explorer/app/run.sh"]
        env:
        - name: TZ
          value: "Asia/Shanghai"
        - name: DATABASE_HOST
          value: {{ $dbHostName }}
        - name: DATABASE_USERNAME
          value: hppoc
        - name: DATABASE_PASSWORD
          value: password
        volumeMounts:
          - mountPath: /fabric/config/explorer/app
            name: fabricfiles
            subPath:  config/explorer/app
          - mountPath: /opt/explorer/logs
            name: fabricfiles
            subPath: crypto-config/peerOrganizations/{{ $orgDomainName }}/explorer/logs
          - mountPath: /opt/explorer/crypto-config
            name: fabricfiles 
            subPath:  crypto-config
          - mountPath: /fabric/config/explorer/app/config
            name: fabricfiles
            subPath:  crypto-config/peerOrganizations/{{ $orgDomainName }}/explorer/config	
      volumes:
      - name: fabricfiles
        persistentVolumeClaim:
          claimName: {{ $pvc }}
		  
---
{{ end }}
