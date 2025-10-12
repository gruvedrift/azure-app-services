#!/bin/bash

set -e

echo "=== Swapping Staging to Production ==="
az webapp deployment slot swap \
  --name tiny-flask-web-app \
  --resource-group tiny-flask-resource-group \
  --slot tiny-flask-staging-slot \
  --target-slot production

echo "=== Swap Complete ==="
echo "Production is now running v2.0"