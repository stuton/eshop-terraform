# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vpc-links.html
locals {
  availability_zone_vpc_links = {
    "us-east-1"    = ["use1-az1", "use1-az2", "use1-az4", "use1-az5", "use1-az6"]
    "us-east-2"    = ["use2-az1", "use2-az2", "use2-az3"]
    "us-west-1"    = ["usw1-az1", "usw1-az3"]
    "us-west-2"    = ["usw2-az1", "usw2-az2", "usw2-az3", "usw2-az4"]
    "ap-east-1"    = ["ape1-az2", "ape1-az3"]
    "ap-south-1"   = ["aps1-az1", "aps1-az2", "aps1-az3"]
    "ca-central-1" = ["cac1-az1", "cac1-az2"]
    "eu-central-1" = ["euc1-az1", "euc1-az2", "euc1-az3"]
    "eu-west-1"    = ["euw1-az1", "euw1-az2", "euw1-az3"]
    "eu-west-2"    = ["euw2-az1", "euw2-az2", "euw2-az3"]
    "eu-west-3"    = ["euw3-az1", "euw3-az3"]
  }
  availability_zone_subnets = {
    for s in data.aws_subnet.public : s.id => s.availability_zone_id if contains(local.availability_zone_vpc_links[data.aws_region.current.name], s.availability_zone_id)
  }
}

##################################################################
# API GATEWAY
# https://github.com/terraform-aws-modules/terraform-aws-apigateway-v2/blob/master/variables.tf
##################################################################

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  create = var.create_api_gateway

  name          = var.name
  description   = var.description
  protocol_type = "HTTP"

  # Only if you use private subnet for ALB
  vpc_links = {
    (var.name) = {
      name               = var.name
      security_group_ids = []
      subnet_ids         = keys(local.availability_zone_subnets)
    }
  }

  cors_configuration = {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  create_api_domain_name      = var.create_api_domain_name
  domain_name                 = "${var.subdomain}.${var.domain}"
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
# ACM
# https://github.com/terraform-aws-modules/terraform-aws-acm/blob/master/variables.tf
################################################################################

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  create_certificate        = var.create_certificate
  domain_name               = var.domain
  zone_id                   = data.aws_route53_zone.this.id
  subject_alternative_names = ["*.${var.domain}"]
}

################################################################################
# Route53
################################################################################

resource "aws_route53_record" "this" {
  count   = var.create_api_gateway ? 1 : 0
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
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_retention_in_days

  tags = var.tags
}

data "aws_region" "current" {}

data "aws_route53_zone" "this" {
  name = var.domain
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["eshop-vpc-public-*"]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)

  id = each.key
}
