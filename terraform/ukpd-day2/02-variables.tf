variable "subscription_id" {
  description = "Azure subscription ID used for UKPropertyDealDesk networking."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for the UKPropertyDealDesk networking platform."
  type        = string
  default     = "uksouth"
}

variable "hub_address_space" {
  description = "Connectivity hub Virtual Network address space."
  type        = list(string)
  default     = ["10.0.0.0/20"]
}

variable "corp_address_space" {
  description = "Corp workload spoke Virtual Network address space."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "firewall_private_ip" {
  description = "Reserved Azure Firewall private IP used by the Corp default route."
  type        = string
  default     = "10.0.0.4"
}
