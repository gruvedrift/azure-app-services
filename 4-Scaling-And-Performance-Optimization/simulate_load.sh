#!/bin/bash

set -e

echo "=== Initiating requests to web app... ==="
cd ./terraform
APP_URL=$(terraform output -raw web_app_url)
ENDPOINT="${APP_URL}/cpu-intensive"

# 6 minutes, 10 concurrent workers, and timout limit set to 120 seconds
echo "Generating sustained CPU load for 6 minutes..."
echo ""
hey -z 6m -c 10 -t  120 "$ENDPOINT?duration=10"

echo "Done!"