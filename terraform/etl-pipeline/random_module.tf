resource "random_password" "dbpassword" {
  length           = 16
  special          = true
  override_special = "_%"
}