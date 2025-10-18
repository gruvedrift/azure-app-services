#!/bin/bash

set -e

echo "=== Initiating requests to web app... ==="
cd ./terraform
APP_URL=$(terraform output -raw web_app_url)

DURATION=120
INTERVAL=3
REQUESTS_ERROR=20
REQUESTS_MEMORY=5
ITERATION=1

while [ $SECONDS -lt $DURATION ]; do
  echo "--- Iteration $ITERATION ---"
  echo "Sending $REQUESTS_MEMORY requests to /memory endpoint..."
  hey -n $REQUESTS_MEMORY -c 1 "$APP_URL/memory"
  echo "Sending $REQUESTS_ERROR requests to /error endpoint..."
  hey -n $REQUESTS_ERROR -c 1 "$APP_URL/error"
  echo "Sleeping $INTERVAL seconds..."
  sleep $INTERVAL
  ITERATION=$((ITERATION + 1))
done

echo "=== Done sending requests ==="
