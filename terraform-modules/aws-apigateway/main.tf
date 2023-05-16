##################################################################
# API GATEWAY
# https://github.com/terraform-aws-modules/terraform-aws-apigateway-v2/blob/master/variables.tf
##################################################################

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  create = var.create_api_gateway

  name          = var.name
  description   = var.description
  protocol_type = "HTTP"

  # Only if you use private subnet for ALB
  vpc_links = {
    (var.app_name) = {
      name = var.app_name
      security_group_ids = []
      subnet_ids = [module.vpc.private_subnets[0]]
    }
  }

  cors_configuration = {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  create_api_domain_name      = var.create_api_domain_name
  domain_name                 = var.domain
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.this.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # authorizers = {
  #   "azure" = {
  #     authorizer_type  = "JWT"
  #     identity_sources = "$request.header.Authorization"
  #     name             = "azure-auth"
  #     audience         = ["d6a38afd-45d6-4874-d1aa-3c5c558aqcc2"]
  #     issuer           = "https://sts.windows.net/aaee026e-8f37-410e-8869-72d9154873e4/"
  #   }
  # }

  tags = var.tags
}

################################################################################
# Route53
################################################################################

resource "aws_route53_record" "this" {
  count = length(module.api_gateway.apigatewayv2_domain_name_configuration) > 0 ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = module.api_gateway.apigatewayv2_domain_name_configuration[0].target_domain_name
    zone_id                = module.api_gateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}


################################################################################
# Supporting Resources
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = var.cloud_watch_log_group_name
  retention_in_days = var.cloudwatch_retention_in_days

  tags = var.tags
}

data "aws_route53_zone" "this" {
  name = var.domain
}
