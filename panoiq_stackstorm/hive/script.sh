#!/bin/bash

# Prompt the user for input
#read -p "Enter repository: " repository
#read -p "Enter tag: " tag
#read -p "Enter database: " database
#read -p "Enter username: " username
#read -s -p "Enter password: " password
#read -p "Enter namespace: " namespace 
#echo

namespace=$1
namespace=$2
server_ip=$3
repository=$3
tag=$4
database=$5
username=$6
password=$7

# Update the values.yaml file
sed -i "s/repository:.*/repository: $repository/" values.yaml
sed -i "s/tag:.*/tag: $tag/" values.yaml
sed -i "s/database:.*/database: $database/" values.yaml
sed -i "s/username:.*/username: $username/" values.yaml
sed -i "s/password:.*/password: $password/" values.yaml

echo "Updated values.yaml file with the provided values."

helm install hive ../hive -n $namespace 


