#!/bin/bash


namespace=$1
server_ip=$2
image=$3
secrets=$4

mkdir -p /tmp/mariadb/manifests/

# Generate PV YAML
cat <<EOF > /tmp/mariadb/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $1
     name: mariadb
  nfs:
    path: /mnt/mariadb
    server: $2
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > /tmp/mariadb/manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
spec:
  accessModes:
  - ReadWriteMany
 #storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Deployment YAML file

cat <<EOF > /tmp/mariadb/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: mariadb

spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      securityContext:
        runAsUser: 65534
        fsGroup: 65534


      containers:
      - env:
        - name: MYSQL_DATABASE
          value: querybook2
        - name: MYSQL_HOST
          value: mariadb:3306
        - name: MYSQL_PASSWORD
          value: passw0rd
        - name: MYSQL_ROOT_PASSWORD
          value: hunter2
        - name: MYSQL_USER
          value: test
 
        image: $3 
        imagePullPolicy: IfNotPresent
        name: mariadb
        ports:
        - containerPort: 3306
          name: mariadb
 
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: mysql-persistent-storage
      restartPolicy: Always
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mariadb
      imagePullSecrets:
      - name: $4
EOF

# Service YAML file
cat <<EOF > /tmp/mariadb/manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: mariadb
  labels:
    app: mariadb
spec:
  type: NodePort
  ports:
    - port: 3306
      targetPort: 3306
      nodePort: 32009
      name: mariadbport
  selector:
    app: mariadb
EOF

echo "YAML files created successfully!"

sudo chmod 1777 /tmp/mariadb/*
# kubernetes deployment



