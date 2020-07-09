{{- define "zookeeper.deployment" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $zooMyID := .zooMyID }}
{{- $zooServers := .zooServers }}
{{- $hostAliases := .hostAliases }}

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
      role: zookeeper
      org: {{ $namespace }}
      zookeeper-id: {{ $name }}
  template:
    metadata:
      labels:
        app: hyperledger
        role: zookeeper
        org: {{ $namespace }}
        zookeeper-id: {{ $name }}
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
        image: hyperledger/fabric-zookeeper:0.4.14
        env:
        - name: ZOO_MY_ID
          value: {{ $zooMyID | quote }}
        - name: ZOO_SERVERS
          value: {{ $zooServers }}
        ports:
         - containerPort: 2181
         - containerPort: 2888
         - containerPort: 3888

---
{{- end }}