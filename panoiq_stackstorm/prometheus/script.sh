#!/bin/bash

# Prompt the user for input
#read -p "Enter defaultprometheusRepository: " repository
#read -p "Enter defaultprometheusTag: " tag
#read -p "Enter secret name: " secretName
#read -p "Enter name of the namespace" namespace

# Input parameters
#read -p "Enter NFS private IP of server: " server_ip

mkdir /tmp/prometheus/manifests

# Generate PV YAML
cat <<EOF > /tmp/prometheus/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv-prometheus
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $1
     name: nfspvc-prometheus
  nfs:
    path: /mnt/prometheus
    server: $2
    readOnly: false
EOF



# Update the values.yaml file
sed -i "s/repository:.*/repository: $repository/" values.yaml
sed -i "s/tag:.*/tag: $tag/" values.yaml
sed -i "s/secretName:.*/secretName: $secretName/" values.yaml

echo "Updated values.yaml file with the provided values"

# kubectl apply -f prometheus-pv.yml

# helm install prometheus ../prometheushelm-chart/ -n $namespace

sudo chmod -R 777 /tmp/prometheus/manifests/
