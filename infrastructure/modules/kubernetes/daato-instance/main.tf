module "auth0" {
  source              = "../../../modules/auth0/daato"
  api_hostname        = var.api_hostname
  frontend_hostname   = var.frontend_hostname
  identifier          = var.identifier
  logo_url            = var.logo_url
  core_api_identifier = var.core_api_identifier
}
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.identifier
  }
}
module "mongodb" {
  source    = "../../mongodb/main"
  namespace = kubernetes_namespace.this.metadata[0].name
}

resource "helm_release" "api" {
  depends_on = [module.mongodb]
  repository = "https://charts.devspace.sh"
  chart      = "component-chart"
  name       = "daato-api"
  namespace  = kubernetes_namespace.this.metadata[0].name
  values     = [
    yamlencode({
      containers = [
        {
          image           = "daato.azurecr.io/api:${var.identifier}"
          imagePullPolicy = "Always"
          env             = [
            for k, v in local.api_env : {
              name  = k
              value = v
            }
          ]
        }
      ]
      pullSecrets = [
        "acr-credentials"
      ]
      service = {
        ports = [
          {
            port = 80
          }
        ]
      }
      ingress = {
        annotations = {
          "nginx.ingress.kubernetes.io/use-regex"      = "true"
          "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
        }
        rules = [
          {
            host = "${var.identifier}.${local.domain}"
            path = "/api(/|$)(.*)"
          }
        ]
      }
    })
  ]
}
resource "helm_release" "frontend" {
  repository       = "https://charts.devspace.sh"
  chart            = "component-chart"
  name             = "daato-frontend"
  namespace        = kubernetes_namespace.this.metadata[0].name
  create_namespace = true
  values           = [
    yamlencode({
      containers = [
        {
          image           = "daato.azurecr.io/frontend:${var.identifier}"
          imagePullPolicy = "Always"
        }
      ]
      pullSecrets = [
        "acr-credentials"
      ]
      service = {
        ports = [
          {
            port = 80
          }
        ]
      }
      ingress = {
        rules = [
          {
            host = "${var.identifier}.${local.domain}"
          }
        ]
      }
    })
  ]
}
output "auth0" {
  value = module.auth0
}