#!/bin/bash

set -e

echo "=== Stage 1: Provisioning Infrastructure ==="
cd ./terraform
terraform init
terraform fmt
terraform validate
terraform apply -auto-approve

# Package and upload application to Web Service
echo "=== Stage 2: Package and upload application code ==="
cd ../src
# Package
zip app.zip app.py requirements.txt
# Upload
az webapp deploy --resource-group tiny-flask-resource-group --name tiny-flask-web-app --src-path app.zip --type zip

