data "kubernetes_secret" "keycloak_credentials" {
  metadata {
    name      = "keycloak-credentials"
    namespace = "default"
  }
}

resource "keycloak_realm" "this" {
  realm                    = var.name
  display_name             = var.display_name != null ? var.display_name : title(var.name)
  login_with_email_allowed = true
  smtp_server {
    host              = "mailpit-smtp.mail"
    port              = 25
    from              = "sysadmin@daato.net"
    from_display_name = "Daato"
  }
}

module "user" {
  source     = "../user"
  first_name = "Daato"
  last_name  = "Admin"
  email      = "sysadmin@daato.net"
  realm      = keycloak_realm.this.id
  username   = "sysadmin"
  password   = data.kubernetes_secret.keycloak_credentials.data.password
}
