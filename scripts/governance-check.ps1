param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "Azure Governance Check"
Write-Host "Resource Group: $ResourceGroupName"
Write-Host "========================================"

$locks = az lock list `
    --resource-group $ResourceGroupName `
    --output json | ConvertFrom-Json

$requiredLock = $locks | Where-Object {
    $_.level -eq "CanNotDelete"
}

if (-not $requiredLock) {
    Write-Error "Required CanNotDelete management lock was not found on '$ResourceGroupName'."
    exit 1
}

Write-Host ""
Write-Host "Governance Check: PASSED"
Write-Host "Required CanNotDelete management lock is present."
Write-Host "Lock Name: $($requiredLock.name)"

exit 0
