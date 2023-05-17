include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-apigateway"

  common_tags = {
    Environment = "dev"
  }
}

inputs = {
  name        = "eshop-api"
  description = "API gateway for eshop application"
  domain      = include.root.locals.domain
  subdomain   = "api" //include.root.locals.subdomains.api

  tags = lookup(local, "tags", null) != null ? merge(local.tags, local.common_tags) : local.common_tags
}
