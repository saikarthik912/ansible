#!/bin/bash

# Define the namespace, label selector, and MongoDB credentials
NAMESPACE="tools"
LABEL_SELECTOR="app=mongodb"
MONGO_USER="root"
MONGO_PASSWORD="root"

# Get the pod name using the label selector
POD_NAME=$(kubectl get pods -n $NAMESPACE -l "$LABEL_SELECTOR" -o jsonpath="{.items[0].metadata.name}")

# Source file path
SOURCE_FILE="/tmp/mongo/data.json"

# Destination path inside the pod
DESTINATION_PATH="/tmp/data.json"

# Copy data.json into the running pod
kubectl cp $SOURCE_FILE $POD_NAME:$DESTINATION_PATH -n $NAMESPACE

# Run the mongoimport command inside the pod with authentication
kubectl exec $POD_NAME -n $NAMESPACE -- bash -c "mongoimport --username $MONGO_USER --password $MONGO_PASSWORD --authenticationDatabase admin --db icondb --collection iconcollection --file $DESTINATION_PATH --jsonArray"
