terraform {
  backend "azurerm" {
    resource_group_name  = "rg-contoso-platform-prod-uks-001"
    storage_account_name = "stcontosogovtf001"
    container_name       = "tfstate"
    key                  = "tfstate/ukpd-day2-networking.tfstate"
    use_azuread_auth     = true
  }
}
