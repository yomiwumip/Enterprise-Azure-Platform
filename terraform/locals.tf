locals {
  resource_group_name = "rg-${var.project_name}-${var.workload}-${var.environment}-${var.region_code}-${var.resource_number}"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CostCentre  = var.cost_centre
    Application = var.application
    ManagedBy   = "Terraform"
  }
}
