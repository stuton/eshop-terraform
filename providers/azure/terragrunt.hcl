locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  subscription_id      = local.env_vars.locals.subscription_id
  tenant_id            = local.env_vars.locals.tenant_id
  env_name             = local.env_vars.locals.env_name
  location             = local.env_vars.locals.location
  resource_group_name  = local.env_vars.locals.resource_group_name
  deployment_storage_resource_group_name = local.env_vars.locals.deployment_storage_resource_group_name
  deployment_storage_account_name        = local.env_vars.locals.deployment_storage_account_name

  default_tags = {
    Environment    = local.env_vars.locals.env_name
    ManagedBy      = "terraform"
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
          version = "=3.55.0"
        }
        azuread = {
            source = "hashicorp/azuread"
            version = "=2.38.0"
        }
      }
    }
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "azurerm"
  config = {
    key                  = "${path_relative_to_include()}/terraform.tfstate"
    subscription_id      = local.subscription_id
    resource_group_name  = local.deployment_storage_resource_group_name
    storage_account_name = local.deployment_storage_account_name
    container_name       = "terraform-state"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.env_vars.locals,
)
