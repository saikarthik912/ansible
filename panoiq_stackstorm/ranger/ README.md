## Ranger Deployment

# Prerequisites
1) Dockerfile
2) Postgres
2) Deployment file
4) service file

## Docker file

Modify install.properties with postgres and elasticsearch parameters and create a  image with the Dockerfile for ranger

```
db_root_user=postgres
db_root_password=postgres
db_host=10.104.144.144:5432
#SSL config
db_ssl_enabled=false
```

## Deployment 

Deploy ranger by using deployment and service files

## Integration of trino with  Ranger

In the TRINO folder we have Dockerfile

Modify install.properties files in that and prepare a docker image and deploy Trino 






## Adding files to the trino mnt folder

Make a file  access-control.properties and add  this parameter access-control.name=ranger into it

Make a file coordinator.properties and add the below parameters into it

coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port=8080
query.max-memory=4GB
query.max-memory-per-node=1GB
memory.heap-headroom-per-node=1GB
discovery-server.enabled=true
discovery.uri=http://localhost:8080
 
 Make a file exchange-manager.properties and add the below parameters into it 

xchange-manager.name=filesystem

exchange.base-directory=/tmp/trino-local-file-system-exchange-manager  (if already  the file exists then no need to create)

Create a file jvm.config an add the below parameters into it

-server
-Xmx8G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
-Djdk.attach.allowAttachSelf=true
-XX:-UseBiasedLocking
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.nio.maxCachedBufferSize=2000000
-XX:+UnlockDiagnosticVMOptions
-XX:+UseAESCTRIntrinsics


Make a file log.properties and add the below parameters into it 
io.trino=INFO

make a file node.properties and add the below parameters

node.environment=production
node.data-dir=/data/trino
plugin.dir=/usr/lib/trino/plugin

Note: if  files are already created then No  need to create them again

## Ranger UI

Access Ranger UI with the service  NodePort 

<hostIp:NodePort>

## TRINO plugin

After accessing Ranger UI. Integrate Trino with jdbc string.






