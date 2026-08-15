variable "location" {
  description = "Azure region for this deployment. UK South is the preferred region unless service, SKU, capacity, resilience, or business requirements require an approved alternative."
  type        = string
  default     = "uksouth"
}

variable "environment" {
  description = "Environment classification for the platform deployment."
  type        = string
  default     = "sandbox"

  validation {
    condition     = contains(["sandbox", "dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: sandbox, dev, test, prod."
  }
}

variable "project_name" {
  description = "Short name identifying the platform project."
  type        = string
  default     = "contoso-platform"
}

variable "owner" {
  description = "Team responsible for the platform resources."
  type        = string
  default     = "Cloud Platform Engineering"
}
