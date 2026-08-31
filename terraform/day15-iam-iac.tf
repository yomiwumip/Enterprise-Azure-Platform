# Day 15 — Enterprise IAM / Cybersecurity Engineering
# Temporary Terraform-managed IAM implementation.

resource "azuread_group" "day15_iam_dev_test" {
  display_name     = "CONTOSO-IAM-DEV-TEST"
  description      = "Temporary Terraform-managed security group for testing enterprise group-based IAM and Azure RBAC."
  security_enabled = true
  mail_enabled     = false
  mail_nickname    = "contoso-iam-dev-test"
}

resource "azuread_user" "day15_iam_dev_test_employee" {
  user_principal_name = "iam.iac.test.employee@ukpropertydealdeskgmail.onmicrosoft.com"
  display_name        = "IAM IaC Test Employee"
  given_name          = "IAM"
  surname             = "IaC Test Employee"
  mail_nickname       = "iam.iac.test.employee"

  password              = var.day15_test_user_password
  force_password_change = true

  lifecycle {
    ignore_changes = [
      password
    ]
  }
  account_enabled = true
}

resource "azuread_group_member" "day15_iam_dev_test_employee" {
  group_object_id  = azuread_group.day15_iam_dev_test.object_id
  member_object_id = azuread_user.day15_iam_dev_test_employee.object_id
}
