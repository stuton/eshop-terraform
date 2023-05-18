include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs-service"

  name                          = "identity-api"
  image_name                    = "winshiftq/identity.api:linux-terraform"
  cloudwatch_log_group_name     = "/aws/ecs/eshop/identity-api"
  autoscaling_capacity_provider = "on-demand-micro"
}

dependency "ecs" {
  config_path = "../base"

  mock_outputs = {
    db_connection_string = "fake"
  }
}

inputs = {
  name                          = local.name
  container_name                = local.name
  service_cpu                   = 128
  service_memory                = 256
  autoscaling_capacity_provider = local.autoscaling_capacity_provider
  cloudwatch_log_group_name     = local.cloudwatch_log_group_name
  container_definitions = templatefile("container_definitions.json", {
    container_name            = local.name
    container_port            = 80
    image                     = local.image_name
    cloudwatch_log_group_name = local.cloudwatch_log_group_name
    region                    = include.root.locals.aws_region
    connection_string         = format("%s;%s", dependency.ecs.outputs.db_connection_string, "Database=Microsoft.eShopOnContainers.Service.IdentityDb;")
    subdomains                = include.root.locals.subdomains
  })
}
