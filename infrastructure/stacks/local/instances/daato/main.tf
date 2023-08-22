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
module "postgres" {
  source    = "../../../../modules/postgres/main"
  namespace = local.namespace
}
