resource "azurerm_virtual_network" "network" {
  name                = "vnet-wlt-tf-prod-uks-001"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.0.0.0/16"]

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

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.0.0/24"]

  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "db" {
  name                 = "snet-db"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.2.0/26"]
}

resource "azurerm_virtual_network" "shared" {
  name                = "vnet-wlt-tf-shared-uks-001"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.1.0.0/16"]

  tags = {
    Company            = "UKPropertyDealDesk"
    Environment        = "Production"
    ManagedBy          = "Terraform"
    Criticality        = "High"
    CostCentre         = "CC-001"
    DataClassification = "Internal"
    BusinessUnit       = "Technology"
    Application        = "Shared-Services"
    Project            = "UKPropertyDealDesk-Platform"
  }
}

resource "azurerm_subnet" "shared_services" {
  name                 = "snet-shared-services"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.shared.name
  address_prefixes     = ["10.1.0.0/24"]

  private_endpoint_network_policies = "Enabled"
}
