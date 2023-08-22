locals {
  service_name = "core"
  namespace    = kubernetes_namespace.this.metadata[0].name
}
resource "kubernetes_namespace" "this" {
  metadata {
    name = local.service_name
  }
}
module "realm" {
  source = "../../../modules/keycloak/realm"
  name   = local.service_name
}
module "cockroachdb" {
  source    = "../../../modules/cockroachdb/main"
  namespace = local.namespace
  name      = "db"
}
