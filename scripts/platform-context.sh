#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo "Azure Platform Health Check"
echo "========================================"

RESOURCE_GROUP_NAME="$(terraform -chdir="$REPO_ROOT/terraform" output -raw resource_group_name)"

if [[ -z "$RESOURCE_GROUP_NAME" ]]; then
    echo "HEALTH: FAILED"
    echo "ERROR: Terraform did not return a Resource Group name."
    exit 1
fi

echo ""
echo "Resource Group: $RESOURCE_GROUP_NAME"

echo ""
echo "Checking Resource Group..."

if ! az group show \
    --name "$RESOURCE_GROUP_NAME" \
    --output table; then
    echo ""
    echo "HEALTH: FAILED"
    echo "ERROR: Resource Group could not be queried."
    exit 1
fi

echo ""
echo "Checking management lock..."

LOCK_COUNT="$(az lock list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --query "[?level=='CanNotDelete'] | length(@)" \
    --output tsv)"

if [[ "$LOCK_COUNT" -eq 0 ]]; then
    echo ""
    echo "HEALTH: FAILED"
    echo "ERROR: Required CanNotDelete management lock was not found."
    exit 1
fi

echo ""
echo "Management Lock: PRESENT"
echo "CanNotDelete locks found: $LOCK_COUNT"

echo ""
echo "========================================"
echo "PLATFORM HEALTH: HEALTHY"
echo "========================================"

exit 0
