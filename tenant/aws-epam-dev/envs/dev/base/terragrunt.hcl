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
  app_name       = "eshop"
  vpc_cidr       = "10.0.0.0/16"
  create_mq      = false
  mq_engine_type = "RabbitMQ"
  mq_engine_version = "3.11.13"
  tags           = lookup(local, "tags", null) != null ? merge(local.tags, local.common_tags) : local.common_tags
}
