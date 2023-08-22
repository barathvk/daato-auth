data "terraform_remote_state" "cluster" {
  backend = "local"
  config  = {
    path = "${path.module}/../cluster/.state/local/cluster.tfstate"
  }
}
locals {
  kube_config             = data.terraform_remote_state.cluster.outputs.credentials
  kube_config_development = data.azurerm_kubernetes_cluster.development.kube_config[0]
  keycloak_credentials    = data.kubernetes_secret.keycloak_credentials.data
}
provider "helm" {
  kubernetes {
    client_certificate     = local.kube_config["client_certificate"]
    cluster_ca_certificate = local.kube_config["cluster_ca_certificate"]
    host                   = local.kube_config["endpoint"]
    client_key             = local.kube_config["client_key"]
  }
}
provider "kubernetes" {
  client_certificate     = local.kube_config["client_certificate"]
  cluster_ca_certificate = local.kube_config["cluster_ca_certificate"]
  host                   = local.kube_config["endpoint"]
  client_key             = local.kube_config["client_key"]
}

data "azurerm_subscriptions" "common" {
  provider            = azurerm.default
  display_name_prefix = "common"
}
provider "azurerm" {
  alias           = "common"
  subscription_id = data.azurerm_subscriptions.common.subscriptions[0]["subscription_id"]
  features {}
}
provider "azurerm" {
  alias = "default"
  features {}
}

data "azurerm_kubernetes_cluster" "development" {
  provider            = azurerm.common
  name                = "daato-development"
  resource_group_name = "daato-development"
}
provider "kubernetes" {
  alias                  = "development"
  client_certificate     = base64decode(local.kube_config_development["client_certificate"])
  client_key             = base64decode(local.kube_config_development["client_key"])
  cluster_ca_certificate = base64decode(local.kube_config_development["cluster_ca_certificate"])
  host                   = local.kube_config_development["host"]
  username               = local.kube_config_development["username"]
  password               = local.kube_config_development["password"]
}
data "kubernetes_secret" "keycloak_credentials" {
  provider = kubernetes.development
  metadata {
    name      = "keycloak-credentials"
    namespace = "default"
  }
}
provider "keycloak" {
  client_id     = "admin-cli"
  url           = local.keycloak_credentials["url"]
  username      = local.keycloak_credentials["username"]
  password      = local.keycloak_credentials["password"]
  initial_login = false
}