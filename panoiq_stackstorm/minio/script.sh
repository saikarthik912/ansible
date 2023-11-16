#!/bin/bash

# Input parameters
#read -p "Enter NFS private IP of server: " server_ip
#read -p "Enter namespace: " namespace

namespace=$1
server_ip=$2
image=$3
secrets=$4
host=$5
MINIO_IDENTITY_OPENID_CONFIG_URL=$6
MINIO_IDENTITY_OPENID_CLIENT_ID=$7
MINIO_IDENTITY_OPENID_CLIENT_SECRET=$8
MINIO_IDENTITY_OPENID_SCOPES=$9

mkdir /tmp/minio/manifests

# Generate PV YAML
cat <<EOF > /tmp/minio/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: minio
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $1
     name: minio
  nfs:
    path: /mnt/minio
    server: $2
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > /tmp/minio/manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio
spec:
  accessModes:
  - ReadWriteMany
 #storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF

# Generate Ingress YAML
cat <<EOF > /tmp/minio/manifests/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minio-ingress
#  annotations:
#    nginx.ingress.kubernetes.io/rewrite-target: /\$1
spec:
  rules:
    - host: $5
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: minio-svc
                port:
                  number: 32005
  ingressClassName: nginx
EOF

# Generate Ingress YAML
cat <<EOF > /tmp/minio/manifests/apiingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minio-api
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /\$1
spec:
  rules:
    - host: $5
      http:
        paths:
          - path: /api/(.*)
            pathType: Prefix
            backend:
              service:
                name: minio-svc
                port: 
                  number: 30625
  ingressClassName: nginx

EOF


# Deployment YAML file
cat <<EOF > /tmp/minio/manifests/deployment.yaml
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: minio
spec:
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: minio
      imagePullSecrets:
      - name: $4

      containers:
      - name: minio
        image: $3
        args:
        - server
        - --console-address
        - :9090
        - /storage
        env:
        - name: MINIO_ROOT_USER
          value: "minio"
        - name: MINIO_ROOT_PASSWORD
          value: "minio123"
        - name: MINIO_IDENTITY_OPENID_CONFIG_URL
          value: $6
        - name: MINIO_IDENTITY_OPENID_CLIENT_ID
          value: $7
        - name: MINIO_IDENTITY_OPENID_CLIENT_SECRET
          value: $8
        - name: MINIO_IDENTITY_OPENID_SCOPES
          value: $9
        - name: MINIO_IDENTITY_OPENID_REDIRECT_URI
          value: "https://testminio.passionbytes.io/oauth_callback"
        - name: MINIO_IDENTITY_OPENID_DISPLAY_NAME
          value: "KEYCLOAK_SSO"
        - name: MINIO_IDENTITY_OPENID_CLAIM_NAME
          value: "policy"
        - name: MINIO_IDENTITY_OPENID_ENABLE
          value: "on"

        ports:
        - protocol: TCP
          containerPort: 9000
        - protocol: TCP
          containerPort: 9090
        volumeMounts:
        - name: storage 
          mountPath: "/storage"
    
EOF


# Service YAML file
cat <<EOF > /tmp/minio/manifests/service.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: minio-svc
  labels:
    app: minio-svc
spec:
  type: NodePort
  ports:
   - name: api
     port: 9000
     nodePort: 30625
     protocol: TCP
     targetPort: 9000
   - name: ui
     port: 9090
     protocol: TCP
     nodePort: 32005
     targetPort: 9090
  selector:
   app: minio
EOF




echo "YAML files created successfully!"

# kubernetes deployment
#sudo chmod 1777 ~/minio*
sudo chmod 777 -R /tmp/minio/manifests/


#kubectl apply -f ~/minio-pv.yaml
#kubectl apply -f ~/minio-pvc.yaml
#kubectl apply -f ~/minio-deployment.yaml
#kubectl apply -f ~/minio-service.yaml
#kubectl apply -f ~/minio-apiingress.yaml
#kubectl apply -f ~/minio-ingress.yaml


