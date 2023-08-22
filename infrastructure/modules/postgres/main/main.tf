resource "random_password" "postgres" {
  length  = 16
  special = false
}
resource "helm_release" "postgres" {
  chart            = "oci://registry-1.docker.io/bitnamicharts/postgresql"
  name             = var.name
  namespace        = var.namespace
  create_namespace = true
  values = [
    yamlencode({
      fullnameOverride = var.name
      global = {
        postgresql = {
          auth = {
            postgresPassword = random_password.postgres.result
          }
        }
      }
      primary = {
        extendedConfiguration = <<-EOF
          wal_level = logical
        EOF
      }
    })
  ]
}
