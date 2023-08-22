data "keycloak_realm" "this" {
  realm = var.realm
}
resource "keycloak_openid_client" "this" {
  realm_id                        = data.keycloak_realm.this.id
  client_id                       = var.client_id
  access_type                     = var.access_type
  direct_access_grants_enabled    = var.access_type == "CONFIDENTIAL" ? true : false
  implicit_flow_enabled           = var.access_type == "CONFIDENTIAL" ? true : false
  standard_flow_enabled           = true
  web_origins                     = var.web_origins
  valid_redirect_uris             = var.redirect_uris
  valid_post_logout_redirect_uris = var.redirect_uris
}
