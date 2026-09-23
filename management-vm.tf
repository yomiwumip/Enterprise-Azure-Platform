resource "azurerm_network_interface" "management" {
  name                = "nic-wlt-tf-mgmt-prod-uks-001"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Company            = "UKPropertyDealDesk"
    Environment        = "Production"
    ManagedBy          = "Terraform"
    Criticality        = "High"
    CostCentre         = "CC-001"
    DataClassification = "Internal"
    BusinessUnit       = "Technology"
    Application        = "Management"
    Project            = "UKPropertyDealDesk-Platform"
  }
}

resource "azurerm_windows_virtual_machine" "management" {
  name                = "vm-wlt-tf-mgmt-prod-uks-001"
  computer_name       = "mgmt-tf-prd-01"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  size                = var.management_vm_size
  zone                = "1"

  admin_username = var.management_vm_admin_username
  admin_password = var.management_vm_admin_password

  network_interface_ids = [
    azurerm_network_interface.management.id
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter-g2"
    version   = "latest"
  }

  os_disk {
    name                 = "osdisk-wlt-tf-mgmt-prod-uks-001"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true

  identity {
    type = "SystemAssigned"
  }

  patch_mode = "AutomaticByOS"

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = {
    Company            = "UKPropertyDealDesk"
    Environment        = "Production"
    ManagedBy          = "Terraform"
    Criticality        = "High"
    CostCentre         = "CC-001"
    DataClassification = "Internal"
    BusinessUnit       = "Technology"
    Application        = "Management"
    Project            = "UKPropertyDealDesk-Platform"
  }
}

resource "azurerm_virtual_machine_extension" "entra_login" {
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.management.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true
}
