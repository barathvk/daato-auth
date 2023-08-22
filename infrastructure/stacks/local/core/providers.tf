data "terraform_remote_state" "cluster" {
  backend = "local"
  config  = {
    path = "${path.module}/../cluster/.state/local/cluster.tfstate"
  }
}
locals {
  kube_config          = data.terraform_remote_state.cluster.outputs.credentials
  keycloak_credentials = data.kubernetes_secret.keycloak_credentials.data
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
data "kubernetes_secret" "keycloak_credentials" {
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