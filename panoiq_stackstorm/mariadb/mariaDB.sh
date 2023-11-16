#!/bin/bash

# Input parameters
read -p "Enter NFS private IP of server: " server_ip
read -p "Enter namespace: " namespace

# Generate PV YAML
cat <<EOF > mariadb-pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv-mariadb
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $namespace
     name: nfspvc-mariadb
  nfs:
    path: /mnt/mariadb
    server: $server_ip
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > mariadb-pvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfspvc-mariadb
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
  name: mariadb-test
  namespace: $namespace

spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb-test
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mariadb-test
    spec:
      securityContext:
        runAsUser: 65534
        fsGroup: 65534


      containers:
      - env:
        - name: MYSQL_DATABASE
          value: querybook2
        - name: MYSQL_HOST
          value: mariadb-test:3306
        - name: MYSQL_PASSWORD
          value: passw0rd
        - name: MYSQL_ROOT_PASSWORD
          value: hunter2
        - name: MYSQL_USER
          value: test
 
        image: REPLACE_IMAGE_NAME 
        imagePullPolicy: IfNotPresent
        name: mariadb-test
        ports:
        - containerPort: 3306
          name: mariadb-test
 
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: mysql-persistent-storage
      restartPolicy: Always
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: nfspvc-mariadb
      imagePullSecrets:
      - name: REPLACE_SECRET_NAME

EOF
)

# Service YAML file
SERVICE_YAML=$(cat <<EOF
apiVersion: v1
kind: Service
metadata:
  name: mariadb-test
  namespace: $namespace 
  labels:
    app: mariadb-test            
spec:
  type: NodePort
  ports:
    - port: 3306
      targetPort: 3306
      nodePort: 32009
      name: mariadbport
  selector:
    app: mariadb-test
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
echo "$DEPLOYMENT_YAML" > mariadb-deployment.yml

# Replace namespace in service YAML
SERVICE_YAML=${SERVICE_YAML//development/$namespace}

# Write service YAML to file
echo "$SERVICE_YAML" > mariadb-service.yml

echo "YAML files created successfully!"

# kubernetes deployment

#kubectl apply -f mariadb-deployment.yml
#kubectl apply -f mariadb-service.yml
#kubectl apply -f mariadb-pv.yml
#kubectl apply -f mariadb-pvc.yml

