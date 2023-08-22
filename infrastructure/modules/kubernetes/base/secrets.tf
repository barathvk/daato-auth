data "azurerm_container_registry" "common" {
  provider            = azurerm.common
  name                = "daato"
  resource_group_name = "daato"
}

module "domain_secret" {
  source = "../synced-secret"
  name   = "domain"
  data   = {
    domain = var.domain
  }
}
module "subscription_secret" {
  source = "../synced-secret"
  name   = "subscription"
  data   = {
    subscription = var.daato_env
  }
}
module "image_pull_secret" {
  source = "../synced-secret"
  name   = "acr-credentials"
  data   = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "daato.azurecr.io" : {
          username = data.azurerm_container_registry.common.admin_username
          password = data.azurerm_container_registry.common.admin_password
          auth     = base64encode("${data.azurerm_container_registry.common.admin_username}:${data.azurerm_container_registry.common.admin_password}")
        }
      }
    })
  }
  type = "kubernetes.io/dockerconfigjson"
}
module "sendgrid" {
  source = "../synced-secret"
  name   = "sendgrid-credentials"
  data   = {
    token = var.sendgrid_token
  }
}