
locals {
  day15_employee_data = {
    for i in range(1, 21) :
    format("emp%03d", i) => {
      employee_id  = format("EMP%03d", i)
      display_name = format("IAM Bulk Test %03d", i)
      upn          = format("iam.bulk.test.%03d@ukpropertydealdeskgmail.onmicrosoft.com", i)
      role_group   = "CONTOSO-IAM-DEV-TEST"
    }
  }
}
