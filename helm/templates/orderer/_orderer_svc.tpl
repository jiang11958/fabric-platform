{{ define "orderer.service" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $orgDomainName := .orgDomainName }}

apiVersion: v1
kind: Service
metadata:
  name: {{ $name }}
  namespace: {{ $namespace }}
  labels:
    domain: {{ $name }}.{{ $orgDomainName }}
    addToHostAliases: "true"
spec:
 type: NodePort
 selector:
   app: hyperledger
   role: orderer
   orderer-id: {{ $name }}
   org: {{ $namespace }}
 ports:
   - name: listen-endpoint
     protocol: TCP
     port: 7050
     targetPort: 7050

---

{{ end }}