#!/bin/bash

# Input parameters
#read -p "Enter NFS private IP of server: " server_ip
#read -p "Enter namespace: " namespace


namespace=$1
server_ip=$2
image=$3
secrets=$4

mkdir /tmp/postgres/manifests


# Generate PV YAML
cat <<EOF > /tmp/postgres/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  claimRef:
     namespace: $1
     name: postgres
  nfs:
    path: /mnt/postgres
    server: $2
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > /tmp/postgres/manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Deployment YAML file
cat <<EOF > /tmp/postgres/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres

  template:
    metadata:
      labels:
        app: postgres

    spec:
      securityContext:
        runAsUser: 65534
        runAsGroup: 65534

      containers:
        - name: postgres
          image: $3
          args: ["-c", "max_connections=500"]
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 5432

          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: postgredb

      volumes:
        - name: postgredb
          persistentVolumeClaim:
            claimName: postgres

      imagePullSecrets:
      - name: $4
EOF


# Service YAML file
cat <<EOF > /tmp/postgres/manifests/service.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  labels:
    app: postgres
spec:
  type: NodePort
  ports:
  -  nodePort: 32292
     port: 5432
     targetPort: 5432
  selector:
   app: postgres
EOF

echo "YAML files created successfully!"


# kubernetes deployment
sudo chmod 777 /tmp/postgres/manifests
