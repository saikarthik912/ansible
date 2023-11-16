#!/bin/sh

sudo yum update -y

sudo rpm -qa | grep nfs-utils -y

sudo yum install nfs-utils rpcbind -y

sudo systemctl restart nfs-server && sudo systemctl enable nfs-server

sudo systemctl restart rpcbind && sudo systemctl restart rpcbind

sudo systemctl start nfs-idmap 

sudo systemctl status nfs-server


# List of directory names
dirnames=(
  "postgress"
  "mongo"
  "mssql"
  "mysql"
  "airdags"
  "airlogs"
  "fileStorageDevelopment"
  "jenkins"
  "minio"
  "redis"
  "sonar"
  "promdata"
  "grafana"
  "promAlertManager"
  "oracle"
  "mariadb"
  "spark"
  "airpostgres"
  "osdata"
  "airConnectors"
  "aircsv"
  "sparkexecutables"
  "redis-db-airflow-redis"
  "certs"
  "pinot-controller"
  "pinot-server"
  "kafka"
  "kafka_data_log"
  "pinot-minion"
  "pinot-zookeeper"
  "iceberg"
  "kafkadeploy-zoo"
  "kafkadeploy"
  "cassandra"
)

# Create directories with permissions and add to /etc/exports
for dirname in "${dirnames[@]}"
do
  dirpath="/mnt/$dirname"
  mkdir -p "$dirpath"
  chmod 1777 "$dirpath"
  echo "$dirpath *(rw)" >> /etc/exports
done

sudo exportfs -r

sudo systemctl restart nfs-server

sudo showmount -e

