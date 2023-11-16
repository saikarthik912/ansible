#!/bin/bash

# Prompt the user for input
read -p "Enter repositoryepository: " repository
read -p "Enter tag: " tag
read -p "Enter secret name: " secretName
read -p "Enter name of the namespace" namespace

# Input parameters
read -p "Enter NFS private IP of server: " server_ip

# Generate PV YAML
cat <<EOF > opensearch-pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv-opensearch
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $namespace
     name: nfspvc-opensearch
  nfs:
    path: /mnt/opensearch
    server: $server_ip
    readOnly: false
EOF

# Update the values.yaml file
sed -i "s/repository:.*/repository: $repository/" values.yaml
sed -i "s/tag:.*/tag: $tag/" values.yaml
sed -i "s/secretName:.*/secretName: $secretName/" values.yaml
# sed -i "s/- name:.*/- name: $name/" values.yaml

echo "Updated values.yaml file with the provided values"

# kubectl apply -f opensearch-pv.yml


# helm install opensearch ../opensearchhelm-chart/ -n $namespace

