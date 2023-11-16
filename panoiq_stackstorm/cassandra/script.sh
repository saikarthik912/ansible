#!/bin/bash

# Input parameters
# read -p "Enter NFS private IP of server: " server_ip
# read -p "Enter namespace: " namespace

#namespace=$1
#server_ip=$2
#image=$3
#secrets=$4

mkdir /tmp/cassandra/manifests/


# Generate PV YAML
cat <<EOF > /tmp/cassandra/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cassandra
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  claimRef:
     namespace: $1
     name: cassandra
  nfs:
    path: /mnt/cassandra
    server: $2
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > /tmp/cassandra/manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cassandra
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Deployment YAML file
cat <<EOF > /tmp/cassandra/manifests/sts.yaml
# Cassandra sts

apiVersion: apps/v1
kind: StatefulSet
metadata:
  generation: 7
  labels:
    app: cassandra
  name: cassandra
spec:
  podManagementPolicy: OrderedReady
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: cassandra
  serviceName: cassandra
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: cassandra
    spec:
      containers:
      - env:
        - name: MAX_HEAP_SIZE
          value: 512M
        - name: HEAP_NEWSIZE
          value: 100M
        - name: CASSANDRA_SEEDS
          value: cassandra-0.cassandra.$1.svc.cluster.local
        - name: CASSANDRA_CLUSTER_NAME
          value: K8Demo
        - name: CASSANDRA_DC
          value: DC1-K8Demo
        - name: CASSANDRA_RACK
          value: Rack1-K8Demo
        - name: POD_IP
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.podIP
        image: $3
        imagePullPolicy: Always
        lifecycle:
          preStop:
            exec:
              command:
              - /bin/sh
              - -c
              - nodetool drain
        name: cassandra
        ports:
        - containerPort: 7000
          name: intra-node
          protocol: TCP
        - containerPort: 7001
          name: tls-intra-node
          protocol: TCP
        - containerPort: 7199
          name: jmx
          protocol: TCP
        - containerPort: 9042
          name: cql
          protocol: TCP
        resources: {}
        securityContext:
          capabilities:
            add:
            - IPC_LOCK
          runAsUser: 999
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /cassandra_data
          name: cassandra-data
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 1800
      volumes:
      - name: cassandra-data
        persistentVolumeClaim:
          claimName: cassandra
  updateStrategy:
    rollingUpdate:
      partition: 0
    type: RollingUpdate
EOF


# Service YAML file
cat <<EOF > /tmp/cassandra/manifests/svc.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cassandra
  name: cassandra
  namespace: $1
spec:
  ports:
  - name: cassandra
    port: 9042
    protocol: TCP
    targetPort: 9042
  selector:
    app: cassandra
  sessionAffinity: None
  type: ClusterIP

EOF


echo "YAML files created successfully!"

# kubernetes deployment



sudo chmod -R 1777 /tmp/cassandra/manifests/*

