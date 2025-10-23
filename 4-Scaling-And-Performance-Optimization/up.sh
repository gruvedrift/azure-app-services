#!/bin/bash

set -e

echo "=== Stage 1: Provisioning Infrastructure ==="
cd ./terraform

terraform init
terraform fmt
terraform validate
terraform apply -auto-approve

WEB_APP_URL=$(terraform output --raw web_app_url)

echo "=== Stage 2: Building .NET Application ==="
cd ../src
dotnet publish -c Release -o ./publish

echo "=== Packaging .NET Application ==="
cd publish
zip -r ../app.zip .
cd ..

echo "=== Deploying Application ==="
az webapp deployment source config-zip \
  --resource-group dotnet-webapp-resource-group \
  --name dotnet-scaling-demo-application \
  --src app.zip

echo "=== Deployment Complete ==="
echo "URL: $WEB_APP_URL"