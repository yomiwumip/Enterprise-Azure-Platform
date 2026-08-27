resource "azurerm_storage_account" "objective9_self_service" {
  name                     = "stcontosobj9tf001"
  resource_group_name      = "rg-contoso-finops-lab-uks-001"
  location                 = "UK South"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  min_tls_version = "TLS1_2"

  public_network_access_enabled = true

  access_tier = "Hot"

  blob_properties {
    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    Environment        = "Development"
    Owner              = "Cloud Platform Team"
    Application        = "Platform Self Service"
    BusinessUnit       = "Technology"
    CostCentre         = "FIN001"
    Criticality        = "Low"
    DataClassification = "Internal"
    ManagedBy          = "Terraform"
  }
}
