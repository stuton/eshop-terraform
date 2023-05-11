include "root" {
  path = find_in_parent_folders()
  expose  = true
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs-service"

  name = "webhooks-client"
  image_name = "winshiftq/webhooks.client:linux-terraform"
  cloudwatch_log_group_name = "/aws/ecs/eshop/webhooks-client"
  route_key = "ANY /site/{proxy+}"
  autoscaling_capacity_provider = "on-demand-micro"
}

dependency "ecs" {
  config_path = "../base"

  mock_outputs = {
    apigatewayv2_id = "fake"
    apigatewayv2_api_api_endpoint = "fake"
    alb_sg_security_group_id = "fake"
  }
}

inputs = {
  name   = local.name
  container_name = local.name
  service_cpu = 256
  service_memory = 512
  route_key = local.route_key
  apigatewayv2_id = dependency.ecs.outputs.apigatewayv2_id
  alb_sg_security_group_id = dependency.ecs.outputs.alb_sg_security_group_id
  autoscaling_capacity_provider = local.autoscaling_capacity_provider
  cloudwatch_log_group_name = local.cloudwatch_log_group_name
  container_definitions = templatefile("container_definitions.json", {
    container_name = local.name
    container_port = 80
    image = local.image_name
    region = include.root.locals.aws_region
    cloudwatch_log_group_name = local.cloudwatch_log_group_name

    identity_url = dependency.ecs.outputs.apigatewayv2_api_api_endpoint
    callback_url = dependency.ecs.outputs.apigatewayv2_api_api_endpoint
    webhooks_url = dependency.ecs.outputs.apigatewayv2_api_api_endpoint
    self_url = dependency.ecs.outputs.apigatewayv2_api_api_endpoint
  })
}