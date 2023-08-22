data "kubernetes_secret" "domain" {
  metadata {
    name      = "domain"
    namespace = "default"
  }
}
locals {
  domain = data.kubernetes_secret.domain.data.domain
}