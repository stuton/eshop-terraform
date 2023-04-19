data "aws_availability_zones" "available" {}

locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  vpc_name_needed = var.create_vpc && length(var.vpc_name) == 0
  vpc_name = local.vpc_name_needed ? "${var.app_name}-vpc" : ""

  cluster_name_needed = var.create_cluster && length(var.cluster_name) == 0
  cluster_name = local.cluster_name_needed ? "${var.app_name}-ecs" : ""

  load_balancer_name_needed = var.create_alb && length(var.load_balancer_name) == 0
  load_balancer_name = local.load_balancer_name_needed ? "${var.app_name}-alb" : ""

  mq_broker_name_needed = var.create_mq && length(var.mq_broker_name) == 0
  mq_broker_name = local.mq_broker_name_needed ? "${var.app_name}-mq" : ""
}

#########################################
# ECS Cluster
#########################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.3"

  create = var.create_cluster

  cluster_name = local.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = var.tags
}

##################################################################
# VPC
##################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  create_vpc = var.create_vpc

  name = local.vpc_name

  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true

  tags = var.tags
}

##################################################################
# Application Load Balancer
##################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.0"

  create_lb = var.create_alb
  name = local.load_balancer_name
  load_balancer_type = var.load_balancer_type

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  # Attach security groups
  security_groups = [module.vpc.default_security_group_id]
  # Attach rules to the created security group
  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  # access_logs = {
  #   bucket = module.log_bucket.s3_bucket_id
  # }

  //tags = var.tags

}

##################################################################
# Amazon MQ
##################################################################

module "mq" {
    source = "cloudposse/mq-broker/aws"
    version     = "3.0.0"
    
    enabled = var.create_mq

    name                       = var.mq_broker_name
    apply_immediately          = true
    auto_minor_version_upgrade = true
    deployment_mode            = var.mq_deployment_mode
    engine_type                = var.mq_engine_type
    engine_version             = var.mq_engine_version
    host_instance_type         = var.mq_host_instance_type
    publicly_accessible        = false
    general_log_enabled        = false
    audit_log_enabled          = false
    encryption_enabled         = true
    use_aws_owned_key          = true
    vpc_id                     = module.vpc.vpc_id
    subnet_ids                 = module.vpc.public_subnets
  }

##################################################################
# Elasticache Redis
##################################################################

# module "redis" {
#   source = "cloudposse/elasticache-redis/aws"
#   version = "0.50.0"

#   availability_zones         = local.azs
#   zone_id                    = var.zone_id
#   vpc_id                     = module.vpc.vpc_id
#   allowed_security_group_ids = [module.vpc.vpc_default_security_group_id]
#   subnets                    = module.subnets.private_subnet_ids
#   cluster_size               = var.cluster_size
#   instance_type              = var.instance_type
#   apply_immediately          = true
#   automatic_failover_enabled = false
#   engine_version             = var.engine_version
#   family                     = var.family
#   at_rest_encryption_enabled = var.at_rest_encryption_enabled
#   transit_encryption_enabled = var.transit_encryption_enabled

#   parameter = [
#     {
#       name  = "notify-keyspace-events"
#       value = "lK"
#     }
#   ]

#   context = module.this.context
# }

################################################################################
# Supporting Resources
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${var.cluster_name}"
  retention_in_days = var.cloudwatch_retention_in_days

  tags = var.tags
}
