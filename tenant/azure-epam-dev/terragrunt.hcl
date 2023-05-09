locals {
  tenant     = "azure-epam-dev"
  subscription_id = "82b365c3-126d-4821-8f5c-9b39d9fb878b"
  location = "francesouth"

  env = basename(dirname(path_relative_to_include()))
  env_name = local.env != "." ? local.env : ""

  default_tags = {
    Tenant    = local.tenant
    ManagedBy = "terraform"
  }

}

# Generate an Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
  subscription_id = "${local.subscription_id}"
}
provider "azuread" {
}
EOF
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        azurerm = {
          source = "hashicorp/azurerm"
          version = "2.95.0"
        }
        azuread = {
            source = "hashicorp/azuread"
            version = "2.18.0"
        }
      }
    }
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "azurerm"
  config = {
      subscription_id = "${local.subscription_id}"
      key = "${path_relative_to_include()}/terraform.tfstate"
      resource_group_name = "rg-terragrunt-eshop"
      storage_account_name = "stterragrunteshop"
      container_name = "environment-states"
  }
  generate = {
      path      = "backend.tf"
      if_exists = "overwrite_terragrunt"
  }
}
