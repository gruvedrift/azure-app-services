#!/bin/bash

set -e

echo "=== Stage 1: Provisioning Core Infrastructure ==="
cd ./terraform
terraform init
terraform fmt
terraform validate

# Apply Azure Resource group, Azure Service Plan
echo "Creating Azure Resource Group and Azure Service Plan...."
terraform apply -target=azurerm_resource_group.tiny-flask \
                -target=azurerm_service_plan.tiny-flask \
                -auto-approve

# Apply Azure Postgres Server,  Azure Postgres Database and Firewall Rule
echo "Creating Azure Postgres Flexible Server and Azure Postgres Flexible Database... "
terraform apply -target=azurerm_postgresql_flexible_server.tiny-flask \
                -target=azurerm_postgresql_flexible_server_database.tiny-flask \
                -target=azurerm_postgresql_flexible_server_firewall_rule.tiny-flask \
                -auto-approve

# Apply Azure Web App
echo "Creating Azure Web App... "
terraform apply -target=azurerm_linux_web_app.tiny-flask \
                -auto-approve

# Package and upload application to Web Service
echo "=== Stage 2: Package and upload application code to Azure Web Service ==="
cd ../src
# Package
zip app.zip app.py requirements.txt
# Upload
az webapp deploy --resource-group tiny-flask-resource-group --name tiny-flask-web-app --src-path app.zip --type zip

