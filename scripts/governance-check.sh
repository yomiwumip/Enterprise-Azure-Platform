#!/usr/bin/env bash

set -euo pipefail

RESOURCE_GROUP_NAME="${1:?Usage: ./scripts/governance-check.sh <resource-group-name>}"

echo "========================================"
echo "Azure Governance Check"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "========================================"

LOCK_COUNT=$(az lock list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --query "[?level=='CanNotDelete'] | length(@)" \
  --output tsv)

if [ "$LOCK_COUNT" -eq 0 ]; then
    echo "Governance Check: FAILED"
    echo "Required CanNotDelete management lock was not found."
    exit 1
fi

echo ""
echo "Governance Check: PASSED"
echo "Required CanNotDelete management lock is present."

az lock list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --query "[?level=='CanNotDelete'].{Name:name,Level:level}" \
  --output table

exit 0
