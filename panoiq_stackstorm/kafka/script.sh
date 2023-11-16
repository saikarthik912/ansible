#!/bin/bash



# Generate PV YAML
cat <<EOF > kafka-pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv-kafkadeploy 
spec:
  capacity:
    storage: 10Gi 
  accessModes:
    - ReadWriteMany 
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  claimRef:
     namespace: "NAMESPACE" 
     name: data-kafka-0
  nfs: 
    path: /mnt/kafkadeploy
    server: "SERVER_IP"
    readOnly: false

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv-kafkadeploy-zoo
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  claimRef:
     namespace: "NAMESPACE"
     name: data-kafka-zookeeper-0
  nfs:
    path: /mnt/kafkadeploy-zoo
    server: "SERVER_IP"
    readOnly: false

EOF


# Update the values.yaml file
echo "Updated values.yaml file with the provided values."


# Adding Volumes
#kubectl apply -f kafka-pv.yml
