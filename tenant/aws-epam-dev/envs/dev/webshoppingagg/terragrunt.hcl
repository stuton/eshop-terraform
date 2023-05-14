include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "${local.source_base_url}"
}

locals {
  source_base_url = "../../../../../terraform-modules/aws-ecs-service"

  service_name                  = "webshoppingagg"
  image_name                    = "winshiftq/webshoppingagg:linux-terraform"
  cloudwatch_log_group_name     = "/aws/ecs/eshop/webshoppingagg"
  route_key                     = "ANY /c/{proxy+}"
  autoscaling_capacity_provider = "on-demand-micro"
}

dependency "ecs" {
  config_path = "../base"

  mock_outputs = {
    mq_connection_uri        = "fake"
    apigatewayv2_id          = "fake"
    alb_sg_security_group_id = "fake"
  }
}

dependency "webspa" {
  config_path = "../webspa"

  mock_outputs = {
    lb_dns_name = "fake"
  }
}

inputs = {
  name                          = local.service_name
  container_name                = local.service_name
  service_cpu                   = 256
  service_memory                = 512
  route_key                     = local.route_key
  apigatewayv2_id               = dependency.ecs.outputs.apigatewayv2_id
  alb_sg_security_group_id      = dependency.ecs.outputs.alb_sg_security_group_id
  autoscaling_capacity_provider = local.autoscaling_capacity_provider
  cloudwatch_log_group_name     = local.cloudwatch_log_group_name
  container_definitions = templatefile("container_definitions.json", {
    container_name            = local.service_name
    container_port            = 80
    image                     = local.image_name
    service_bus_host          = dependency.ecs.outputs.mq_connection_uri
    cloudwatch_log_group_name = local.cloudwatch_log_group_name
    region                    = include.root.locals.aws_region
    backet_url                = dependency.webspa.outputs.lb_dns_name
    catalog_url               = dependency.webspa.outputs.lb_dns_name
    payment_url               = dependency.webspa.outputs.lb_dns_name
    ordering_url              = dependency.webspa.outputs.lb_dns_name
    identity_url              = dependency.webspa.outputs.lb_dns_name
    identity_ext_url          = dependency.webspa.outputs.lb_dns_name
  })
}
