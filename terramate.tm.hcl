terramate {
  config {
    git {
      check_untracked   = false
      check_uncommitted = false
      check_remote      = false
    }
  }
}
generate_hcl "backend.tm.tf" {
  condition = global.daato_env != "local"
  content {
    terraform {
      backend "azurerm" {
        container_name       = "clusters"
        resource_group_name  = "daato-tfstate"
        storage_account_name = "daatotfstate"
        key                  = "${global.daato_env}/${terramate.stack.path.basename}.tfstate"
      }
    }
  }
}
generate_hcl "backend.tm.tf" {
  condition = global.daato_env == "local"
  content {
    terraform {
      backend "local" {
        path = ".state/${global.daato_env}/${terramate.stack.path.basename}.tfstate"
      }
    }
  }
}