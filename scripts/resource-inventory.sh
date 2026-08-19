#!/usr/bin/env bash

set -euo pipefail

RESOURCE_GROUP_NAME="${1:?Usage: ./scripts/resource-inventory.sh <resource-group-name>}"

echo "========================================"
echo "Azure Resource Inventory"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "========================================"

echo ""
echo "RESOURCE GROUP"
az group show \
  --name "$RESOURCE_GROUP_NAME" \
  --output table

echo ""
echo "RESOURCES"
az resource list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --output table

echo ""
echo "MANAGEMENT LOCKS"
az lock list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --output table

echo ""
echo "Inventory completed successfully."
