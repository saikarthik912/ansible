#!/bin/bash

namespace=$1
server_ip=$2
image=$3
secrets=$4

mkdir /tmp/grafana/manifests

# Generate PV YAML
cat <<EOF > /tmp/grafana/manifests/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: grafana
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $1
     name: grafana
  nfs:
    path: /mnt/grafana
    server: $2
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > /tmp/grafana/manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana
spec:
  accessModes:
  - ReadWriteMany
 #storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Configmap YAML file

cat <<EOF > /tmp/grafana/manifests/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
data:
  prometheus.yaml: |-
    {
        "apiVersion": 1,
        "datasources": [
            {
               "access":"proxy",
                "editable": true,
                "name": "prometheus",
                "orgId": 1,
                "type": "prometheus",
                "url": "$url",
                "version": 1
            }
        ]
    }
EOF


# Deployment YAML file


cat <<EOF > /tmp/grafana/manifests/deployment.yaml
# grafana deployment

apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      name: grafana
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: $3
        imagePullPolicy: Always
        securityContext:
          runAsUser: 0
          runAsGroup: 0
          # fsGroup: 2000
          privileged: true        
        ports:
        - name: grafana
          containerPort: 3000
        volumeMounts:
          - mountPath: /var/lib/grafana
            name: grafana-storage
          - mountPath: /etc/grafana/provisioning/datasources
            name: grafana-datasources
            readOnly: false
      volumes:
        - name: grafana-storage
          persistentVolumeClaim:
            claimName: grafana
        - name: grafana-datasources
          configMap:
              defaultMode: 420
              name: grafana-datasources
       
      imagePullSecrets:
      - name: $4

EOF


# Service YAML file

cat <<EOF > /tmp/grafana/manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/port:   '3000'
spec:
  selector: 
    app: grafana
  type: NodePort  
  ports:
    - port: 3000
      targetPort: 3000
      nodePort: 32000
EOF



echo "YAML files created successfully!"

# kubernetes deployment
#sudo chmod 1777 ~/grafana*
#sudo chmod 777 grafana-*

sudo chmod 777 -R /tmp/grafana/manifests/

#kubectl apply -f ~/configmap.yml
#kubectl apply -f ~/deployment.yml
#kubectl apply -f ~/service.yml
#kubectl apply -f ~/grafana-pv.yml
#kubectl apply -f ~/grafana-pvc.yml



