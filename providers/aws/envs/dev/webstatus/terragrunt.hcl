include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs-service"

  service_name                  = "webstatus"
  image_name                    = "winshiftq/webstatus:linux-terraform"
  cloudwatch_log_group_name     = "/aws/ecs/eshop/webstatus"
  route_key                     = "ANY /c/{proxy+}"
  autoscaling_capacity_provider = "on-demand-micro"
  health_check_path             = "/"
}

dependency "ecs" {
  config_path = "../base"

  mock_outputs = {
    mq_connection_uri = "fake"
  }
}

inputs = {
  name                          = local.service_name
  container_name                = local.service_name
  service_cpu                   = 128
  service_memory                = 256
  route_key                     = local.route_key
  autoscaling_capacity_provider = local.autoscaling_capacity_provider
  cloudwatch_log_group_name     = local.cloudwatch_log_group_name
  health_check_path             = local.health_check_path
  container_definitions = templatefile("container_definitions.json", {
    container_name            = local.service_name
    container_port            = 80
    image                     = local.image_name
    service_bus_host          = dependency.ecs.outputs.mq_connection_uri
    cloudwatch_log_group_name = local.cloudwatch_log_group_name
    region                    = include.root.locals.aws_region
    discovery_services        = include.root.locals.discovery_services
  })
}
