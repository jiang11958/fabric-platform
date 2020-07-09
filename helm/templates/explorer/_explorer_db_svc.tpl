{{- define "explorer.db.service" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $orgName := .orgName }}
{{- $orgDomainName := .orgDomainName }}

apiVersion: v1
kind: Service
metadata:
  namespace: {{ $namespace }}
  name: {{ $name }}
  labels:
    run: {{ $name }}
spec:
  type: NodePort 
  selector:
    db-id: {{ $name }}
  ports:
  - protocol: TCP
    port: 5432
    targetPort: 5432 
    name: pgsql
	
---
{{- end }}