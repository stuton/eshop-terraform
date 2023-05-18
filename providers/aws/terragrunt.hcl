locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  account_id          = local.env_vars.locals.account_id
  aws_region          = local.env_vars.locals.aws_region
  env_name            = local.env_vars.locals.env_name
  bucket_name         = local.env_vars.locals.bucket_name
  dynamodb_table_name = local.env_vars.locals.dynamodb_table_name

  domain             = local.env_vars.locals.domain
  subdomains         = local.env_vars.locals.subdomains
  discovery_services = local.env_vars.locals.discovery_services

  default_tags = {
    Environment = local.env_vars.locals.env_name
    ManagedBy   = "terraform"
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

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "4.67.0"
        }
      }
    }
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = local.bucket_name
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = local.dynamodb_table_name
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.env_vars.locals,
)
