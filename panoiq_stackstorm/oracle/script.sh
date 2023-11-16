#!/bin/bash

# Input parameters
#read -p "Enter NFS private IP of server: " server_ip
#read -p "Enter namespace: " namespace


namespace=$1
server_ip=$2
image=$3
secrets=$4


mkdir /tmp/oracle/manifests/


# Generate PV YAML
cat <<EOF > /tmp/oracle/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: oracle
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  claimRef:
     namespace: $1
     name: oracle
  nfs:
    path: /mnt/oracle
    server: $2
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > /tmp/oracle/manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: oracle
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Deployment YAML file
cat <<EOF > /tmp/oracle/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oracledb
  labels:
    app: oracledb
spec:
  selector:
    matchLabels:
      app: oracledb
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: oracledb
    spec:
      #affinity:
        #nodeAffinity:
          #requiredDuringSchedulingIgnoredDuringExecution:
            #nodeSelectorTerms:
            #- matchExpressions:
              #- key: node
                #operator: In
                #values:
                #- worker1            
      containers:
#      - image: javiermugueta/oracledb
#      - image: fra.ocir.io/<tenantname>/atrepo/orcldb:latest
#      - image: amd64/oraclelinux:8
      - image: $3
        name: oracledb
        ports:
        - containerPort: 1521
          name: oracledb
        volumeMounts:
        - name: data
          mountPath: /ORCL
        env:
         - name: ORACLE_SID
           value: orcl
      securityContext:
        runAsNonRoot: true
        runAsUser: 54321
        fsGroup: 54321
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: oracle
      imagePullSecrets:
       - name: registry 
EOF


# Service YAML file
cat <<EOF > /tmp/oracle/manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
 name: oracledb
spec:
 type: LoadBalancer
 selector:
   app: oracledb
 ports:
   - name: client
     protocol: TCP
     port: 1521
     nodePort: 31521
 selector:
   app: oracledb

EOF



echo "YAML files created successfully!"

# kubernetes deployment

sudo chmod -R  1777 /tmp/oracle/*


