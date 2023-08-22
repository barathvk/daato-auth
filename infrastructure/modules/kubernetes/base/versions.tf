terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    azurerm = {
      source                = "hashicorp/azurerm"
      //noinspection HILUnresolvedReference
      configuration_aliases = [azurerm.common]
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}