#!/usr/bin/bash

# variables
AWX_GIT_URL=https://github.com/ansible/awx-operator.git
AWX_CLONE_PATH="/opt/awx-operator"
AWX_TAG='2.19.1'
KUSTOMIZATION_URL="https://raw.githubusercontent.com/JershBytes/awx-setup/refs/heads/main/config/kustomization.yaml"
AWX_YAML_URL="https://github.com/JershBytes/awx-setup/blob/main/config/awx.yml"
FILENAME="kustomization.yaml"
HOST_IP=$(hostname -I | cut -d' ' -f1)

# Install k3s
echo "Installing k3s..."
curl -sfL https://get.k3s.io | sh -

### AWX Setup ###

echo "Installing and Setting up AWX..."

# Clone awx repo
git clone "$AWX_GIT_URL" "$AWX_CLONE_PATH" && cd "$AWX_CLONE_PATH" || exit

# set tag version
git checkout "$AWX_TAG"

# Create awx
make deploy

# Grab kustomization.yaml
curl -O $KUSTOMIZATION_URL

# Install the manifests and check to see if its running after
kubectl apply -k . && watch -n5 kubectl get pods -n awx

# set the current namespace for kubectl
kubectl config set-context --current --namespace=awx

# grab awx.yml file
curl -O $AWX_YAML_URL && sed -i 's/^# - awx.yml/  - awx.yml/' $FILENAME

# Confirm the change
echo "Updated $FILENAME:"
cat $FILENAME

# Apply the changes
kubectl apply -k .

# Grab port info
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"

# Job's done
echo "AWX has been installed successfully and should now be running at http://${HOST_IP}, use the password below to sign in."

# Grab admin password
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode ; echo











