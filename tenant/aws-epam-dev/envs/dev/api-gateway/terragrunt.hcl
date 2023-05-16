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
  create_api_gateway = false
  name               = "eshop-api"
  description        = "API gateway for eshop application"
  domain             = include.root.locals.domain
  subdomain          = "api" //include.root.locals.subdomains.api

  cloudwatch_log_group_name = "/aws/ecs/eshop"

  tags = lookup(local, "tags", null) != null ? merge(local.tags, local.common_tags) : local.common_tags
}
