globals {
  az_subscription = "common"
  az_location     = "West Europe"
}

generate_hcl "locals.tm.tf" {
  content {
    locals {
      daato_env       = global.daato_env
      az_subscription = global.az_subscription
      az_location     = global.az_location
      domain          = global.domain
    }
  }
}