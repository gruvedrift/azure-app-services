#!/bin/bash

set -e

echo "=== Stage 1: Provisioning Infrastructure ==="
cd ./terraform

terraform init
terraform fmt
terraform validate
terraform apply -auto-approve

# Set environment variables for later use
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
ACR_NAME=$(terraform output -raw acr_name)

# Package and upload application to Web Service
cd ../src

echo "Logging into Azure Container Registry..."
az acr login --name $ACR_NAME

echo "=== Stage 2: Building and Pushing Container Image ==="
echo "[COMMAND] build --platform linux/amd64 -t ${ACR_LOGIN_SERVER}/tiny-flask-monitoring:latest ."
docker build --platform linux/amd64 -t $ACR_LOGIN_SERVER/tiny-flask-monitoring:latest .

echo "Pushing image to Azure Container Registry..."
echo "[COMMAND] docker push ${ACR_LOGIN_SERVER}/tiny-flask-monitoring:latest"
docker push $ACR_LOGIN_SERVER/tiny-flask-monitoring:latest