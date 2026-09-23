resource "azurerm_network_security_group" "app" {
  name                = "nsg-tf-app"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  security_rule = []

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

resource "azurerm_network_security_group" "db" {
  name                = "nsg-tf-db"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

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

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db.id

}
