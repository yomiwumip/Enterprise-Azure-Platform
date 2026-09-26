locals {
  hub_resource_group  = "rg-ukpd-connectivity-hub-prod-uks"
  corp_resource_group = "rg-ukpd-corp-network-prod-uks"

  hub_vnet_name  = "vnet-ukpd-hub-prod-uks-001"
  corp_vnet_name = "vnet-ukpd-corp-prod-uks-001"

  common_tags = {
    Company           = "UKPropertyDealDesk"
    Environment       = "Production"
    ManagedBy         = "Terraform"
    Application       = "Platform-Networking"
    BusinessUnit      = "Technology"
    Owner             = "Platform Engineering"
    CostCentre        = "CC-001"
    DataClassification = "Internal"
    Criticality       = "High"
    Project           = "UKPropertyDealDesk-Platform"
  }
}
