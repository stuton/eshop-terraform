locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  tenant     = "aws-epam-dev"
  account_id = local.env_vars.locals.account_id
  aws_region = local.env_vars.locals.aws_region
  env_name = local.env_vars.locals.env_name

  domain = local.env_vars.locals.domain
  subdomains = local.env_vars.locals.subdomains
  discovery_services = local.env_vars.locals.discovery_services

  bucket     = join("-", ["terragrunt-state-${local.tenant}", "${local.env_name}", "${local.aws_region}"])
  dynamodb_table = join("-", ["terragrunt-locks-${local.tenant}", "${local.env_name}", "${local.aws_region}"])

  default_tags = {
    Tenant    = local.tenant
    ManagedBy = "terraform"
  }

}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region              = "${local.aws_region}"
  allowed_account_ids = ["${local.account_id}"]
  # default_tags {
  #   tags = ${jsonencode(local.default_tags)}
  # }
}
provider "aws" {
  alias               = "virginia"
  region              = "us-east-1"
}
EOF
}

# generate "versions" {
#   path      = "versions_override.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
#     terraform {
#       required_providers {
#         cloudflare = {
#           source = "cloudflare/cloudflare"
#           version = "2.12.0"
#         }
#       }
#     }
# EOF
# }

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = local.bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = local.dynamodb_table
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.env_vars.locals,
)
