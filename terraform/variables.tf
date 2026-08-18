variable "location" {
  description = "Azure region for this deployment."
  type        = string
  default     = "uksouth"
}

variable "environment" {
  description = "Environment classification for the platform deployment."
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["sandbox", "dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: sandbox, dev, test, prod."
  }
}

variable "project_name" {
  description = "Short name identifying the platform project."
  type        = string
  default     = "contoso"
}

variable "workload" {
  description = "Platform workload or service purpose."
  type        = string
  default     = "platform"
}

variable "region_code" {
  description = "Short Azure region code used in resource names."
  type        = string
  default     = "uks"
}

variable "resource_number" {
  description = "Sequential identifier for resources in the same naming scope."
  type        = string
  default     = "001"
}

variable "owner" {
  description = "Team responsible for the platform resources."
  type        = string
  default     = "Cloud Platform Engineering"
}

variable "cost_centre" {
  description = "Cost centre used for platform cost allocation."
  type        = string
  default     = "IT001"
}

variable "application" {
  description = "Application or platform service associated with the resource."
  type        = string
  default     = "Platform"
}
