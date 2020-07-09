{{- define "peer.service" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $orgName := .orgName }}
{{- $orgDomainName := .orgDomainName }}

apiVersion: v1
kind: Service
metadata:
  namespace: {{ $namespace }}
  name: {{ $name }}-{{ $orgName }}
  labels:
    domain: {{ $name }}.{{ $orgDomainName }}
    addToHostAliases: "true"
spec:
  type: NodePort
  selector:
    app: hyperledger
    role: peer
    peer-id: {{ $name }}.{{ $orgDomainName }}
    org: {{ $namespace }}
  ports:
    - name: externale-listen-endpoint
      protocol: TCP
      port: 7051
      targetPort: 7051
    - name: chaincode-listen
      protocol: TCP
      port: 7052
      targetPort: 7052
    #- name: listen
    #  protocol: TCP
    #  port: 7053
    #  targetPort: 7053

---
{{- end }}