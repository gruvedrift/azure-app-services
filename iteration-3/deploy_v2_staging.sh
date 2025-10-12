#!/bin/bash

set -e

cd ./terraform
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
ACR_NAME=$(terraform output -raw acr_name)

cd ../src
echo "=== Building and Pushing v2 to Registry ==="

az acr login --name $ACR_NAME

echo "Building application v2.0..."
docker build --platform linux/amd64 -t ${ACR_LOGIN_SERVER}/tiny-flask-web-app:v2.0 .

echo "Pushing Docker image to ACR..."
docker push ${ACR_LOGIN_SERVER}/tiny-flask-web-app:v2.0

echo "=== Updating Staging Slot Configuration ==="
# Update staging slot to pull v2.0 application image
az webapp config container set \
  --name tiny-flask-web-app \
  --resource-group tiny-flask-resource-group \
  --slot tiny-flask-staging-slot \
  --container-image-name ${ACR_LOGIN_SERVER}/tiny-flask-web-app:v2.0

# Update the non-sticky APPLICATION_VERSION setting for the staging environment
az webapp config appsettings set \
  --name tiny-flask-web-app \
  --resource-group tiny-flask-resource-group \
  --slot tiny-flask-staging-slot \
  --settings APPLICATION_VERSION="v2.0"

echo "Staging environment updated!"
