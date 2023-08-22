resource "helm_release" "cockroachdb" {
  repository       = "https://charts.cockroachdb.com"
  chart            = "cockroachdb"
  name             = var.name
  namespace        = var.namespace
  create_namespace = true
  values = [
    yamlencode({
      fullnameOverride = var.name
      statefulset = {
        replicas = 1
      }
      conf = {
        single-node = true
      }
      tls = {
        enabled = false
      }
    })
  ]
}
