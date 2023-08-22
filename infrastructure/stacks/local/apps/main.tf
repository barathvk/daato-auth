module "base_kubernetes" {
  providers = {
    azurerm.common = azurerm.common
  }
  source         = "../../../modules/kubernetes/base"
  domain         = local.domain
  daato_env      = local.daato_env
  sendgrid_token = var.sendgrid_token
  is_local       = true
}
module "tls" {
  depends_on = [module.base_kubernetes]
  source     = "../../../modules/local/tls"
  domain     = local.domain
}
module "keycloak" {
  source = "../../../modules/keycloak/main"
}
