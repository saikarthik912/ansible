#!/bin/bash

# Input parameters
read -p "Enter NFS private IP of server: " server_ip
read -p "Enter namespace: " namespace
read -p "Enter url for Prometheus: " url
read -p "Enter the secret name to pull the image: " secret
read -p "Enter the name and tag of the image: " grafanaimg

# Generate PV YAML
cat <<EOF > grafana-pv.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv-grafana
spec:
  capacity:
    storage: 7Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  #storageClassName: local-storage
  claimRef:
     namespace: $namespace
     name: nfspvc-grafana
  nfs:
    path: /mnt/grafana
    server: $server_ip
    readOnly: false
EOF

# Generate PVC YAML
cat <<EOF > grafana-pvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfspvc-grafana
  namespace: $namespace
spec:
  accessModes:
  - ReadWriteMany
 #storageClassName: local-storage    
  resources:
     requests:
       storage: 5Gi
EOF



# Configmap YAML file

cat <<EOF > configmap.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
  namespace: $namespace
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


cat <<EOF > deployment.yml
# grafana deployment

apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: $namespace
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
        image: $namespace
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
            claimName: nfspvc-grafana
        - name: grafana-datasources
          configMap:
              defaultMode: 420
              name: grafana-datasources
       
      imagePullSecrets:
      - name: $secret

EOF


# Service YAML file

cat <<EOF > service.yml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: $namespace
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

# kubectl apply -f grafana-sts.yml
# kubectl apply -f grafana-service.yml
# kubectl apply -f grafana-pv.yml
# kubectl apply -f grafana-pvc.yml


