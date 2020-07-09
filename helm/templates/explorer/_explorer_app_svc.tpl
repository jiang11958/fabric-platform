{{- define "explorer.app.service" }}

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
    app-id: {{ $name }}
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080 
    name: pgsql
	
---
{{- end }}