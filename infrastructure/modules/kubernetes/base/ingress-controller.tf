resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  wait             = true
  values           = [
    yamlencode({
      defaultBackend = {
        enabled = true
      }
      controller = {
        config = {
          "force-ssl-redirect"    = "true"
          "use-forwarded-headers" = "true"
          "use-proxy-protocol"    = "false"
          "use-http"              = "true"
          "proxy-body-size"       = "1024m"
          "proxy-buffer-size"     = "1024k"
        }
        terminationGracePeriodSeconds = 0
        watchIngressWithoutClass      = true
        service                       = {
          externalTrafficPolicy = "Local"
        }
      }
    }),
    yamlencode(var.is_local ? local.ingress_controller.local : {}),
    yamlencode(!var.is_local ? local.ingress_controller.azurerm : {})
  ]
}