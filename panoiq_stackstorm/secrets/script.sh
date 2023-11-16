#!/bin/bash

# Get input values
#read -p "Enter GitLab registry name: " registry
#read -p "Enter GitLab username: " username
#read -s -p "Enter GitLab password: " password
#echo
#read -p "Enter namespace: " namespace


#namespace=$1
#server_ip=$2
#image=$3
#secrets=$4



# Encode username:password as base64
auth=$(echo -n "$1:$2" | base64)

# Create JSON object
json="{\"auths\": {\"$3\": {\"auth\": \"$auth\"}}}"

# Encode JSON object as base64
encoded=$(echo -n "$json" | base64)

# Create YAML file
cat <<EOF > secret.yaml
apiVersion: v1
data:
  .dockerconfigjson: $encoded
kind: Secret
metadata:
  name: registry
  namespace: $4
type: kubernetes.io/dockerconfigjson
EOF

# Create namespace 
cat <<EOF > namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tools
EOF


# Output YAML file
#cat secret.yaml

echo "YAML files created successfully!"

# kubernetes deployment
sudo chmod 1777 ~/secret*
sudo chmod 777 secret*

kubectl apply -f ~/secret.yaml
# kubectl apply -f namspace.yaml




