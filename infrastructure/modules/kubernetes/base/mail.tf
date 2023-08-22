resource "helm_release" "sendgrid_mail" {
  repository       = "https://djjudas21.github.io/charts"
  chart            = "smtp-relay"
  name             = "sendgrid"
  namespace        = "mail"
  create_namespace = true
  values           = [
    yamlencode({
      nameOverride = "sendgrid"
      smtp         = {
        host     = "[smtp.sendgrid.net]:587"
        username = "apikey"
        password = var.sendgrid_token
      }
    })
  ]
}
resource "helm_release" "mailpit" {
  depends_on = [helm_release.sendgrid_mail]
  repository = "https://jouve.github.io/charts"
  chart      = "mailpit"
  name       = "mailpit"
  namespace  = "mail"
  values     = [
    yamlencode({
      ingress = {
        enabled  = true
        hostname = "mail.${var.domain}"
        path     = "/"
      }
    })
  ]
}
