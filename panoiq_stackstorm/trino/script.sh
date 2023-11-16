#!/bin/bash


namespace=$1
image=$2
repository=$3
tag=$4


# Update the values.yaml file
sed -i "s/repository:.*/repository: $repository/" values.yaml
sed -i "s/tag:.*/tag: $tag/" values.yaml
sed -i "s/host:.*/host: $host/" values.yaml



echo "Updated values.yaml file with the provided values."

helm intall trino ../trino -n $namespace


