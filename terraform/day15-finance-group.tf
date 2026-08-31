resource "azuread_group" "day15_finance" {
  display_name     = "CONTOSO-IAM-FINANCE"
  description      = "Finance security group for role-based enterprise access management."
  security_enabled = true
  mail_enabled     = false
  mail_nickname    = "contoso-iam-finance"
}
