include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs-service"

  service_name                  = "ordering-api"
  image_name                    = "winshiftq/ordering.api:linux-terraform"
  cloudwatch_log_group_name     = "/aws/ecs/eshop/ordering-api"
  route_key                     = "ANY /o/{proxy+}"
  autoscaling_capacity_provider = "on-demand-micro"
}

dependency "ecs" {
  config_path = "../base"

  mock_outputs = {
    mq_connection_uri    = "fake"
    db_connection_string = "fake"
  }
}

dependency "api_gateway" {
  config_path = "../api-gateway"

  mock_outputs = {
    apigatewayv2_id = "fake"
  }
}

inputs = {
  name                            = local.service_name
  container_name                  = local.service_name
  service_cpu                     = 128
  service_memory                  = 256
  route_key                       = local.route_key
  autoscaling_capacity_provider   = local.autoscaling_capacity_provider
  cloudwatch_log_group_name       = local.cloudwatch_log_group_name
  create_apigatewayv2_integration = true
  apigatewayv2_id                 = dependency.api_gateway.outputs.apigatewayv2_id
  route_key                       = local.route_key
  container_definitions = templatefile("container_definitions.json", {
    container_name            = local.service_name
    container_port            = 80
    container_grpc_port       = 81
    image                     = local.image_name
    service_bus_host          = dependency.ecs.outputs.mq_connection_uri
    cloudwatch_log_group_name = local.cloudwatch_log_group_name
    region                    = include.root.locals.aws_region
    connection_string         = format("%s;%s", dependency.ecs.outputs.db_connection_string, "Database=Microsoft.eShopOnContainers.Service.OrderingDb;")
    subdomains                = include.root.locals.subdomains
    discovery_services        = include.root.locals.discovery_services
  })
}
