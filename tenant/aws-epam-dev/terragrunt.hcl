locals {
  tenant     = "aws-epam-dev"
  account_id = "326106872578"
  aws_region = "eu-west-3"

  env = basename(dirname(path_relative_to_include()))
  env_name = local.env != "." ? local.env : ""

  bucket     = join("-", ["terraform-state-${local.tenant}", "${local.env_name}", "${local.aws_region}"])
  dynamodb_table = join("-", ["terraform-locks-${local.tenant}", "${local.env_name}", "${local.aws_region}"])

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
