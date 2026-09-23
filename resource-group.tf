resource "azurerm_resource_group" "network" {
  name     = "rg-wlt-network-tf-prod-uks-001"
  location = "uksouth"

  tags = {
    Company            = "UKPropertyDealDesk"
    Environment        = "Production"
    ManagedBy          = "Terraform"
    Criticality        = "High"
    CostCentre         = "CC-001"
    DataClassification = "Internal"
    BusinessUnit       = "Technology"
    Application        = "Networking"
    Project            = "UKPropertyDealDesk-Platform"
  }
}
