locals {
  ingress_controller = {
    azurerm = {
      controller = {
        service = {
          type = "LoadBalancer"
        }
      }
    }
    local = {
      controller = {
        hostPort = {
          enabled = true
        }
        service = {
          type = "NodePort"
        }
        nodeSelector = {
          "ingress-ready" = "true"
        }
        tolerations = [
          {
            key      = "node-role.kubernetes.io/control-plane"
            operator = "Equal"
            effect   = "NoSchedule"
          },
          {
            key      = "node-role.kubernetes.io/master"
            operator = "Equal"
            effect   = "NoSchedule"
          }
        ]
        publishService = {
          enabled = false
        }
        extraArgs = {
          "publish-status-address"  = "localhost"
          "default-ssl-certificate" = "default/wildcard-tls"
        }
      }
    }
  }
}