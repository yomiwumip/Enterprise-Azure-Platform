param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "Azure Resource Inventory"
Write-Host "Resource Group: $ResourceGroupName"
Write-Host "========================================"

Write-Host ""
Write-Host "Checking Resource Group..."

az group show `
    --name $ResourceGroupName `
    --output table

if ($LASTEXITCODE -ne 0) {
    Write-Error "Resource Group '$ResourceGroupName' could not be found or queried."
    exit 1
}

Write-Host ""
Write-Host "RESOURCE GROUP"
az group show `
    --name $ResourceGroupName `
    --output table

Write-Host ""
Write-Host "RESOURCES"
az resource list `
    --resource-group $ResourceGroupName `
    --output table

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to retrieve resources from '$ResourceGroupName'."
    exit 1
}

Write-Host ""
Write-Host "MANAGEMENT LOCKS"
az lock list `
    --resource-group $ResourceGroupName `
    --output table

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to retrieve management locks from '$ResourceGroupName'."
    exit 1
}

Write-Host ""
Write-Host "Inventory completed successfully."
exit 0
