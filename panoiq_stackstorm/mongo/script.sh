#!/bin/bash

# Input parameters
# read -p "Enter NFS private IP of server: " server_ip
# read -p "Enter namespace: " namespace

namespace=$1
server_ip=$2
image=$3
secrets=$4

mkdir /tmp/mongo/manifests/

# Generate PV YAML
cat <<EOF > /tmp/mongo/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mongo
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $1
     name: mongo
  nfs:
    path: /mnt/mongo
    server: $2
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > /tmp/mongo/manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo
  namespace: $1
spec:
  accessModes:
  - ReadWriteMany
 #storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Deployment YAML file
cat <<EOF > /tmp/mongo/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:

  labels:
    app: mongodb
  name: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  strategy: {}
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      securityContext:
       runAsUser: 65534


      containers:
      - image: $3
        name: mongodb
        imagePullPolicy: IfNotPresent
        args: ["--dbpath","/data/db"]

        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          value: root
        - name: MONGO_INITDB_ROOT_PASSWORD
          value: root

        volumeMounts:
        - name: "mongo-data-dir"
          mountPath: "/data/db"


    # initContainers:
    # - name: fix-ownership
    #    image: alpine:3.6
    #    command: ["chown", "-R", "1000:100", "/data/"]


      volumes:
      - name: "mongo-data-dir"
        persistentVolumeClaim:
          claimName: "mongo"

      imagePullSecrets:
      - name: $4
EOF


# Service YAML file
cat <<EOF > /tmp/mongo/manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-svc
  labels:
    app: mongo
spec:
  ports:
  - name: mongo
    port: 27017
    targetPort: 27017
  type: ClusterIP
  selector:
    app: mongodb
EOF


echo "YAML files created successfully!"

whoiam
sudo chmod -R  1777 /tmp/mongo/*
