#!/bin/bash

# Input parameters
# read -p "Enter NFS private IP of server: " server_ip
# read -p "Enter namespace: " namespace

namespace=$1
server_ip=$2
image=$3
secrets=$4


mkdir /tmp/mysql/manifests/

# Generate PV YAML
cat <<EOF > /tmp/mysql/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $1
     name: mysql
  nfs:
    path: /mnt/mysql
    server: $2
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > /tmp/mysql/manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql
spec:
  accessModes:
  - ReadWriteMany
 #storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Deployment YAML file
cat <<EOF > /tmp/mysql/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      securityContext:
        runAsUser: 999
        #allowPrivilegeEscalation: false
        #runAsGroup: 3000
        fsGroup: 999
        #fsGroupChangePolicy: "OnRootMismatch"
      containers:  

      - image: $3
      #- image: mysql:5.6  
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: panoiq
 

          # command: ["/bin/sh", "-c", "chmod 777 /usr/sbin/mysqld", chown /var/lib/mysql, ls /var/lib/mysql/]
        ports:
        - containerPort: 3306
          name: mysql
       
          #initContainers:
          #- name: fix-ownership
          #image: alpine:3.6
          #command: ["chown", "-R", "0", "/var/lib/mysql"]
                              
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql
      
      imagePullSecrets:
      - name: $4

EOF

# Service YAML file
cat <<EOF > /tmp/mysql/manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  type: NodePort
  ports:
   - port: 3306
     nodePort: 30992
     targetPort: 3306
  selector:
    app: mysql

EOF

echo "YAML files created successfully!"

sudo chmod -R  1777 /tmp/mysql/*

# kubernetes deployment

