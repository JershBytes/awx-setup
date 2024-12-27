#!/usr/bin/bash

# variables
awx_clone_path="/opt/awx"
awx_tag='2.19.1'

# dependencies function
install-dependencies() {

# Install k3s
curl -sfL https://get.k3s.io | sh -

# Install dependencies
yum -y install git make jq vim
}

### AWX Setup ###

# Install the needful
install-dependencies

# Clone awx repo
git clone git@github.com:ansible/awx-operator.git "$awx_clone_path" && cd /opt/awx || exit

# set tag version
git checkout "$awx_tag"

# Create awx
make deploy

# Install the manifests and check to see if its running after
kubectl apply -k . && kubectl get pods -n awx

# set the current namespace for kubectl
kubectl config set-context --current --namespace=awx









