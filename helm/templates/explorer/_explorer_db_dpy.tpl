{{ define "explorer.db.deployment" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
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
       db-id: {{ $name }}
  template:
    metadata:
      labels:
        db-id: {{ $name }}
    spec:
      containers:
      - name: postgres
        image: postgres:10.4-alpine
        env:
        - name: TZ
          value: "Asia/Shanghai"
        - name: DATABASE_DATABASE
          value: fabricexplorer
        - name: DATABASE_USERNAME
          value: hppoc
        - name: DATABASE_PASSWORD
          value: password	
        lifecycle:
            postStart:
              exec:
                command: ["/bin/sh", "-c", "/fabric/config/explorer/db/init_db.sh"]		
        volumeMounts:
          - mountPath: /fabric/config/explorer/db
            name: fabricfiles
            subPath:  config/explorer/db     
      volumes:
      - name: fabricfiles
        persistentVolumeClaim:
          claimName: {{ $pvc }}
		  
---
{{ end }}
