include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs"

  common_tags = {
    Environment="dev"
  }
}

inputs = {
  vpc_name       = "eshop-vpc"
  cluster_name   = "eshop-app"
  tags           = lookup(local, "tags", null) != null ? merge(local.tags, local.common_tags) : local.common_tags
}
