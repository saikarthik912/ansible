#!/bin/bash

# Input parameters
#read -p "Enter NFS private IP of server: " server_ip
#read -p "Enter namespace: " namespace

namespace=$1
server_ip=$2
image=$3
secret=$4
host=$5

# Ingress YAML file

mkdir /tmp/ranger/manifests

cat <<EOF > /tmp/ranger/manifests/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ranger-ingress
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
                name: ranger-admin
                port:
                  number: 32448
  ingressClassName: nginx
EOF


# Deployment YAML file

cat <<EOF > /tmp/ranger/manifests/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: ranger-admin-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ranger-admin-server
  template:
    metadata:
        labels:
          app: ranger-admin-server
    spec:
      containers:
        - name: ranger-admin-server
          image: $3
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 6080
              protocol: TCP
      imagePullSecrets:
      - name: $4
EOF



# Service YAML file
cat <<EOF > /tmp/ranger/manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ranger-admin
spec:
  type: NodePort
  ports:
    - name: http
      port: 6080
      nodePort: 32448 
      protocol: TCP
      targetPort: 6080
  selector:
    app: ranger-admin-server
EOF



echo "YAML files created successfully!"

# kubernetes deployment
sudo chmod 777 -R /tmp/ranger/manifests/
