resource "random_password" "keycloak_admin" {
  length  = 16
  special = false
}
resource "helm_release" "keycloak" {
  repository       = "https://codecentric.github.io/helm-charts"
  chart            = "keycloakx"
  name             = var.name
  namespace        = var.namespace
  create_namespace = true
  values           = [
    yamlencode({
      fullnameOverride = var.name
      command          = [
        "/opt/keycloak/bin/kc.sh",
        "start",
        "--http-enabled=true",
        "--http-port=8080",
        "--hostname-strict=false",
        "--hostname-strict-https=false",
        "--hostname-admin-url=https://auth.${local.domain}",
        "--hostname-url=https://auth.${local.domain}"
      ]
      http = {
        relativePath = "/"
      }
      extraEnv = yamlencode([
        {
          name  = "KEYCLOAK_ADMIN"
          value = "sysadmin@daato.net"
        },
        {
          name  = "KEYCLOAK_ADMIN_PASSWORD"
          value = random_password.keycloak_admin.result
        },
        {
          name  = "KC_PROXY"
          value = "passthrough"
        },
        {
          name  = "PROXY_ADDRESS_FORWARDING"
          value = "true"
        },
        {
          name  = "KEYCLOAK_FRONTEND_URL"
          value = "https://auth.${local.domain}"
        },
        {
          name  = "JAVA_OPTS_APPEND"
          value = "-Djgroups.dns.query=keycloak-keycloak-headless"
        }
      ])
      ingress = {
        enabled     = true
        annotations = {
          "nginx.ingress.kubernetes.io/proxy-buffer-size" : "128k"
        }
        rules = [
          {
            host  = "auth.${local.domain}"
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
              }
            ]
          }
        ]
      }
    })
  ]
}
module "keycloak_credentials" {
  source = "../../kubernetes/synced-secret"
  name   = "keycloak-credentials"
  data   = {
    url      = "https://auth.${local.domain}"
    username = "sysadmin@daato.net"
    password = random_password.keycloak_admin.result
  }
}
