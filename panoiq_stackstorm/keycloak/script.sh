#!/bin/bash

# Input parameters
#read -p "Enter NFS private IP of server: " server_ip
#read -p "Enter namespace: " namespace

server_ip=$2
image=$3
secret=$4
host=$5

mkdir /tmp/keycloak/manifests/

# Generate Ingress YAML

cat <<EOF > /tmp/keycloak/manifests/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
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
                name: keycloak
                port:
                  number: 32001
  ingressClassName: nginx
EOF



# Deployment YAML file
cat <<EOF > /tmp/keycloak/manifests/deployment.yaml
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak
  serviceName: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
      - env:
        - name: BITNAMI_DEBUG
          value: "false"
        - name: KEYCLOAK_ADMIN_PASSWORD
          value: admin
        - name: KEYCLOAK_DATABASE_PASSWORD
          value: key
        - name: KEYCLOAK_HTTP_RELATIVE_PATH
          value: /
        - name: KEYCLOAK_ADMIN
          value: admin
        - name: KEYCLOAK_CACHE_TYPE
          value: local
        - name: KEYCLOAK_DATABASE_HOST
          value: postgres.tools
        - name: KEYCLOAK_DATABASE_NAME
          value: key
        - name: KEYCLOAK_DATABASE_PORT
          value: "5432"
        - name: KEYCLOAK_DATABASE_USER
          value: key
        - name: KEYCLOAK_ENABLE_STATISTICS
          value: "false"
        - name: KEYCLOAK_ENABLE_TLS
          value: "false"
        - name: KEYCLOAK_HTTP_PORT
          value: "8080"
        - name: KEYCLOAK_LOG_OUTPUT
          value: default
        - name: KEYCLOAK_PROXY
          value: passthrough
        image: $3
        imagePullPolicy: Always
        name: keycloak
        ports:
        - containerPort: 32001
          name: http
          protocol: TCP
        resources: {}
      imagePullSecrets:
      - name: $4
EOF


# Service YAML file
cat <<EOF > /tmp/keycloak/manifests/service.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
  labels:
    app: keycloak
spec:
  type: NodePort
  ports:
   - port: 8080
     nodePort: 32001
     targetPort: 8080
  selector:
   app: keycloak
EOF




echo "YAML files created successfully!"

# kubernetes deployment
sudo chmod 1777 /tmp/keycloak/manifests/

#kubectl apply -f ~/keycloak-deployment.yml
#kubectl apply -f ~/keycloak-service.yml
#kubectl apply -f ~/keycloak-ingress.yml
 
