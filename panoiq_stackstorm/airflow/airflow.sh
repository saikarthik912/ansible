#!/bin/bash

# Prompt the user for input
#read -p "Enter defaultAirflowRepository: " defaultAirflowRepository
#read -p "Enter defaultAirflowTag: " defaultAirflowTag
#read -p "Enter airflowdb user: " dbUser
#read -s -p "Enter airflowdb password: " dbPassword
#read -p "Enter airflowdb host: " dbHost
#read -p "Enter airflowdb database: " dbName
#read -p "Enter secret name: " secretName
#read -p "Enter name of the namespace" namespace

# Input parameters
#read -p "Enter NFS private IP of server: " server_ip

# Generate PV YAML
cat <<EOF > airflowDag-pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: airflowDag
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $namespace
     name: nfspvc-airflowDag
  nfs:
    path: /mnt/airflowdag
    server: $server_ip
    readOnly: false
EOF


cat <<EOF > airflowLog-pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: airflowLog
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $namespace
     name: nfspvc-airflowLog
  nfs:
    path: /mnt/airflowlog
    server: $server_ip
    readOnly: false
EOF

# Update the values.yaml file
sed -i "s/defaultAirflowRepository:.*/defaultAirflowRepository: $defaultAirflowRepository/" values.yaml
sed -i "s/defaultAirflowTag:.*/defaultAirflowTag: $defaultAirflowTag/" values.yaml
sed -i "s/user:.*/user: $dbUser/" values.yaml
sed -i "s/pass:.*/pass: $dbPassword/" values.yaml
sed -i "s/host:.*/host: $dbHost/" values.yaml
sed -i "s/db:.*/db: $dbName/" values.yaml
sed -i "s/secretName:.*/secretName: $secretName/" values.yaml

echo "Updated values.yaml file with the provided values"

kubectl apply -f airflowDag-pv.yml
kubectl apply -f airflowLog-pv.yml


helm install airflow ../airflowhelm-chart/ -n $namespace
