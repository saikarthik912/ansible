#!/bin/sh

wget https://get.helm.sh/helm-v3.11.3-linux-amd64.tar.gz

tar -xvf helm-v3.11.3-linux-amd64.tar.gz

sudo cp linux-amd64/helm /usr/bin/

sudo chmod +x /usr/bin/helm

helm version


