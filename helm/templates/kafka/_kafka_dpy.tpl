{{- define "kafka.deployment" }}

{{- $namespace := .namespace }}
{{- $name := .name }}
{{- $brokerID := .brokerID }}
{{- $zookeeperConnect := .zookeeperConnect}}
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
      role: kafka
      org: {{ $namespace }}
      kafka-id: {{ $name }}
  template:
    metadata:
      labels:
        app: hyperledger
        role: kafka
        org: {{ $namespace }}
        kafka-id: {{ $name }}
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
        image: hyperledger/fabric-kafka:0.4.14
        env:
        - name: KAFKA_MESSAGE_MAX_BYTES
          value: "1048576"
        - name: KAFKA_REPLICA_FETCH_MAX_BYTES
          value: "1048576"
        - name: KAFKA_UNCLEAN_LEADER_ELECTION_ENABLE
          value: "false"
        - name: KAFKA_BROKER_ID
          value: {{ $brokerID | quote }}
        - name: KAFKA_MIN_INSYNC_REPLICAS
          value: "2"
        - name: KAFKA_DEFAULT_REPLICATION_FACTOR
          value: "3"
        - name: KAFKA_ZOOKEEPER_CONNECT
          value: {{ $zookeeperConnect | quote }}
        - name: KAFKA_ADVERTISED_HOST_NAME
          value: {{ $name }}
        ports:
         - containerPort: 9092

---
{{- end }}