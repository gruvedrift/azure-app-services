#!/bin/bash

set -e


echo "=== Initiating requests to web app... ==="
cd ./terraform
APP_URL=$(terraform output -raw web_app_url)

# Random number between [0-10]
for endpoint in "/" "/slow" "/error" "/memory"; do
  REQUESTS=$(($RANDOM%(10-0+1)+0))
  echo "Sending request to: $endpoint"
  hey -n $REQUESTS -c 1 "$APP_URL$endpoint"
done

echo "=== Done sending requests ==="
