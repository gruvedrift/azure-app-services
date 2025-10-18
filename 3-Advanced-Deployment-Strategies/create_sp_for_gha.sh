#!/bin/bash

set -e

echo "Creating Service Principal for GitHub actions..."
az ad sp create-for-rbac \
  --name "github-action-tiny-flask-sp" \
  --role Contributor \
  --scopes /subscriptions/8f9aed58-aa08-45bd-960a-2c15d4449132/resourceGroups/tiny-flask-resource-group \
  --sdk-auth

echo "Finished creating Service Principal"
