#!/bin/bash

# Input parameters
read -p "Enter NFS private IP of server: " server_ip
read -p "Enter namespace: " namespace

# Generate PV YAML
cat <<EOF > mysql-pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv-mysql
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $namespace
     name: nfspvc-mysql
  nfs:
    path: /mnt/mysql
    server: $server_ip
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > mysql-pvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfspvc-mysql
  namespace: $namespace
spec:
  accessModes:
  - ReadWriteMany
 #storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Deployment YAML file
DEPLOYMENT_YAML=$(cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: $namespace
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

      - image: REPLACE_IMAGE_NAME
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
          claimName: nfspvc-mysql
      
      imagePullSecrets:
      - name: REPLACE_SECRET_NAME

EOF
)

# Service YAML file
SERVICE_YAML=$(cat <<EOF
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: $namespace
spec:
  type: NodePort
  ports:
   - port: 3306
     nodePort: 30992
     targetPort: 3306
  selector:
    app: mysql

EOF
)

# Read input parameters
read -p "Enter image name: " image
read -p "Enter secrets name: " secrets

# Replace placeholders in deployment YAML
DEPLOYMENT_YAML=${DEPLOYMENT_YAML//REPLACE_IMAGE_NAME/$image}
DEPLOYMENT_YAML=${DEPLOYMENT_YAML//REPLACE_SECRET_NAME/$secrets}
DEPLOYMENT_YAML=${DEPLOYMENT_YAML//development/$namespace}

# Write deployment YAML to file
echo "$DEPLOYMENT_YAML" > mysql-deployment.yml

# Replace namespace in service YAML
SERVICE_YAML=${SERVICE_YAML//development/$namespace}

# Write service YAML to file
echo "$SERVICE_YAML" > mysql-service.yml

echo "YAML files created successfully!"

# kubernetes deployment

#kubectl apply -f mysql-deployment.yml
#kubectl apply -f mysql-service.yml
#kubectl apply -f mysql-pv.yml
#kubectl apply -f mysql-pvc.yml
