#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo "Azure Platform Diagnostic"
echo "========================================"

RESOURCE_GROUP_NAME="$(terraform -chdir="$REPO_ROOT/terraform" output -raw resource_group_name)"

if [[ -z "$RESOURCE_GROUP_NAME" ]]; then
    echo "DIAGNOSTIC: FAILED"
    echo "ERROR: Terraform did not return a Resource Group name."
    exit 1
fi

echo ""
echo "Resource Group: $RESOURCE_GROUP_NAME"

echo ""
echo "RESOURCE GROUP"
az group show \
    --name "$RESOURCE_GROUP_NAME" \
    --output table

RESOURCE_COUNT="$(az resource list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --query "length(@)" \
    --output tsv)"

LOCK_COUNT="$(az lock list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --query "length(@)" \
    --output tsv)"

echo ""
echo "DIAGNOSTIC SUMMARY"
echo "Resource count: $RESOURCE_COUNT"
echo "Management lock count: $LOCK_COUNT"

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
echo "========================================"
echo "PLATFORM DIAGNOSTIC: COMPLETE"
echo "========================================"

exit 0
