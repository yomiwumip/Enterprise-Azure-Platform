resource "azurerm_public_ip" "bastion" {
  name                = "pip-tf-bastion-prod-uks-001"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"

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

resource "azurerm_bastion_host" "network" {
  name                = "bas-wlt-tf-prod-uks-001"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku                 = "Standard"

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

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
