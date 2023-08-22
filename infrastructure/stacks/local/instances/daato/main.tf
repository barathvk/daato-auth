locals {
  service_name = "daato"
  namespace    = kubernetes_namespace.this.metadata[0].name
}
resource "kubernetes_namespace" "this" {
  metadata {
    name = local.service_name
  }
}
module "realm" {
  source = "../../../../modules/keycloak/realm"
  name   = local.service_name
}
module "api_keycloak_client" {
  source      = "../../../../modules/keycloak/client"
  client_id   = "daato-api"
  access_type = "CONFIDENTIAL"
  realm       = module.realm.realm.realm
}
resource "kubernetes_secret" "api_client" {
  metadata {
    name      = "daato-api-keycloak-config"
    namespace = local.namespace
  }
  data = {
    clientId     = module.api_keycloak_client.client_id
    clientSecret = module.api_keycloak_client.client_secret
    realm        = module.realm.realm.realm
  }
}
module "cockroachdb" {
  source    = "../../../../modules/cockroachdb/main"
  namespace = local.namespace
  name      = "db"
}
