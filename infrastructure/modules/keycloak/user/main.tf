data "keycloak_realm" "this" {
  realm = var.realm
}
resource "random_password" "this" {
  length  = 16
  special = false
}
resource "keycloak_user" "admin" {
  realm_id       = data.keycloak_realm.this.id
  username       = var.username
  email          = var.email
  email_verified = true
  first_name     = var.first_name
  last_name      = var.last_name
  initial_password {
    value     = var.password != null ? var.password : random_password.this.result
    temporary = var.password != null ? false : true
  }
}
