## pinot installation 
```
helm repo add pinot https://raw.githubusercontent.com/apache/pinot/master/kubernetes/helm
kubectl create ns pinot-quickstart
helm install pinot pinot/pinot \
    -n pinot-quickstart \
    --set cluster.name=pinot \
    --set server.replicaCount=2
```
### Create a Mount point in the NFS server as shown below

```
sudo mkdir /mnt/pinot

sudo chmod 1777 /mnt/pinot

```

### Edit the /etc/exports file and add the details of the directory previously created with read write permissions

```
sudo vim /etc/exports
---------------------
/mnt/pinot  *(rw)



---------------------
```

```
sudo exportfs -r

```

```
sudo systemctl restart nfs-server

```
### Check the mount added is available for use inside Persistent Volume

```
showmount -e

```
 
 ## pv file
 Attach the mount path in the pv file as below
 ```
 apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfspv-pinot
  namespace: development
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  claimRef:
     namespace: development
     name: nfspvc-pinot
  nfs:
    path: /mnt/pinot
    server: 172.31.22.109
    readOnly: false
```
```
kubctl apply -f pv.yaml
```

## pvc file
Modify the changes in the pvc file as below
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfspvc-pinot
  namespace: development
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 7Gi
```
``` 
kubectl apply -f pvc.yaml
```
# Attach the mount path volumes in pinot deployment file
 
# creating sample tables and schemas in pinot

# Go to Pinot folder and apply the below yaml files
```
kubectl apply -f pinot-realtime-quickstart.yml
```
# you can see the created schemas and tables in pinot UI

## Pinot integration with MINIO
## Modify pinot configmap as below
```
  pinot-controller.conf: |-
    controller.helix.cluster.name=pinot-quickstart
    controller.port=9000
    #controller.host=pinot-controller
    #controller.data.dir=/var/pinot/controller/data
    controller.zk.str=pinot-zookeeper:2181
    #pinot.set.instance.id.to.hostname=true
    #controller.task.scheduler.enabled=true
    #controller.segment.fetcher.auth.token=Basic YWRtaW46dmVyeXNlY3JldA
    controller.data.dir=s3://pinotdata
    controller.local.temp.dir=/tmp/pinot-tmp-data/
    controller.host=pinot-controller-0.pinot-controller-headless.development.svc.cluster.local
    pinot.controller.storage.factory.s3.endpoint=http://10.98.233.70:9000
    pinot.controller.storage.factory.s3.accessKey=miniostorage
    pinot.controller.storage.factory.s3.secretkKey=miniostorage
    pinot.controller.storage.factory.class.s3=org.apache.pinot.plugin.filesystem.S3PinotFS
    pinot.controller.storage.factory.s3.region=us-west-2
    pinot.controller.segment.fetcher.protocols=file,http,s3
    pinot.controller.segment.fetcher.s3.class=org.apache.pinot.common.utils.fetcher.PinotFSSegmentFetcher
    pinot.controller.storage.factory.s3.disableAcl=false
```
## Create access key in minio and give as an env variable in pinot deployment file as below
```
  spec:
      affinity: {}
      containers:
      - args:
        - StartController
        - -configFileName
        - /var/pinot/controller/config/pinot-controller.conf
        env:
        - name: AWS_ACCESS_KEY_ID
          value: miniostorage
        - name: AWS_SECRET_ACCESS_KEY
          value: miniostorage
```
