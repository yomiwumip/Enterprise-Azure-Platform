variable "management_vm_size" {
  description = "Azure VM size for the production management server."
  type        = string
  default     = "Standard_D2nls_v6"
}

variable "management_vm_admin_username" {
  description = "Local administrator username used during initial Windows VM provisioning."
  type        = string
  default     = "azureadmin"
}

variable "management_vm_admin_password" {
  description = "Initial local administrator password for the management VM."
  type        = string
  sensitive   = true
}
