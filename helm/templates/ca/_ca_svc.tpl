{{ define "ca.service" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $orgDomainName := .orgDomainName }}
{{- $domain := .domain }}

apiVersion: v1
kind: Service
metadata:
   namespace: {{ $namespace }}
   name: {{ $name }}
   labels:
      domain: {{ $domain }}
spec:
 type: NodePort
 selector:
   app: hyperledger
   role: ca
   org: {{ $orgDomainName }}
   name: ca
 ports:
   - name: endpoint
     protocol: TCP
     port: 7054
     targetPort: 7054

---
{{ end }}