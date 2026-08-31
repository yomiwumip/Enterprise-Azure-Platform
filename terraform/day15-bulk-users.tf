resource "azuread_user" "day15_bulk_employee" {
  for_each = local.day15_employee_data

  user_principal_name   = each.value.upn
  display_name          = each.value.display_name
  mail_nickname         = each.value.employee_id
  password              = var.day15_bulk_test_user_password
  force_password_change = true

  lifecycle {
    ignore_changes = [
      password
    ]
  }
  account_enabled = true
}
