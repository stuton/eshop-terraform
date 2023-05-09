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
# Autoscaling
# https://github.com/terraform-aws-modules/terraform-aws-autoscaling/blob/master/variables.tf
#########################################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  for_each = {
    # On-demand instances
    on-demand-micro = {
      instance_type              = "t2.micro"
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      min_size                   = 1
      max_size                   = 2
      desired_capacity           = 1
      user_data                  = <<-EOT
        #!/bin/bash
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${local.cluster_name}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(var.tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
      EOT
    }
  }

  name = var.app_name

  key_name = "anton-epam-workstation"

  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = each.value.instance_type

  security_groups                 = [module.autoscaling_sg.security_group_id]
  user_data                       = base64encode(each.value.user_data)
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = "ecsInstanceRole"
  iam_role_description        = "ECS role for ${var.app_name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = module.vpc.public_subnets

  health_check_type   = "EC2"
  min_size            = each.value.min_size
  max_size            = each.value.max_size
  desired_capacity    = each.value.desired_capacity

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  # Spot instances
  use_mixed_instances_policy = each.value.use_mixed_instances_policy
  mixed_instances_policy     = each.value.mixed_instances_policy

  depends_on = [
    module.db,
    module.mq
  ]

  tags = var.tags
}


#########################################
# ECS Cluster
# https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/variables.tf
#########################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

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

  cluster_service_connect_defaults = {
    namespace = aws_service_discovery_private_dns_namespace.this.arn
  }

  default_capacity_provider_use_fargate = false

  autoscaling_capacity_providers = {
    # On-demand instances
    on-demand-micro = {
      auto_scaling_group_arn         = module.autoscaling["on-demand-micro"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 1
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }

  depends_on = [
    module.db,
    module.mq
  ]

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

  enable_nat_gateway = false
  single_nat_gateway = false
  enable_dns_hostnames = true

  tags = var.tags
}

##################################################################
# Security Groups
##################################################################

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.app_name
  description = "Autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-tcp" //all tcp
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]

  tags = var.tags
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.app_name
  description = "Application loadbalancer security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = module.vpc.public_subnets_cidr_blocks

  tags = var.tags
}

##################################################################
# Amazon MQ
# https://github.com/cloudposse/terraform-aws-mq-broker/blob/master/variables.tf
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
    publicly_accessible        = true
    create_security_group      = false
    general_log_enabled        = false
    audit_log_enabled          = false
    encryption_enabled         = true
    use_aws_owned_key          = true
    vpc_id                     = module.vpc.vpc_id
    subnet_ids                 = var.mq_deployment_mode == "SINGLE_INSTANCE" ? [module.vpc.public_subnets[0]] : module.vpc.public_subnets
}

##################################################################
# RDS
# https://github.com/terraform-aws-modules/terraform-aws-rds/blob/master/variables.tf
##################################################################

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.6.0"

  create_db_instance = var.create_database_instance
  identifier = var.database_instance_name

  engine            = var.database_engine
  engine_version    = var.database_engine_version
  instance_class    = var.database_instance_class
  allocated_storage = var.database_allocated_storage
  storage_encrypted = var.database_storage_encrypted

  db_name  = var.database_name
  username = var.database_username
  port     = var.database_port

  skip_final_snapshot = true
  allow_major_version_upgrade = var.database_allow_major_version_upgrade

  iam_database_authentication_enabled = var.database_iam_database_authentication_enabled

  vpc_security_group_ids = [module.rds_sg.security_group_id]

  publicly_accessible    = var.database_publicly_accessible
  # monitoring_interval = "30"
  # monitoring_role_name = "MyRDSMonitoringRole"
  # create_monitoring_role = true

  enabled_cloudwatch_logs_exports = ["error"]
  create_cloudwatch_log_group     = true

  tags = var.tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.public_subnets

  # DB parameter group
  family = var.database_family

  # DB option group
  major_engine_version = var.database_major_engine_version

  # Database Deletion Protection
  deletion_protection = var.database_deletion_protection

  parameters = var.database_parameters

  options = var.database_options
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "rds-sg"
  description = "RDS security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["mssql-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = module.vpc.public_subnets_cidr_blocks

  tags = var.tags
}

##################################################################
# API GATEWAY
# https://github.com/terraform-aws-modules/terraform-aws-apigateway-v2/blob/master/variables.tf
##################################################################

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  create = var.create_api_gateway

  name          = var.app_name
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  create_api_domain_name           = false

  # Only if you use private subnet for ALB
  # vpc_links = {
  #   (var.app_name) = {
  #     name = var.app_name
  #     security_group_ids = []
  #     subnet_ids = [module.vpc.public_subnets[0]]
  #   }
  # }

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  # domain_name                 = "terraform-aws-modules.modules.tf"
  # domain_name_certificate_arn = "arn:aws:acm:eu-west-1:052235179155:certificate/2b3a7ed9-05e1-4f9e-952b-27744ba06da6"

  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.apigateway.arn
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
# Service discovery namespaces
################################################################################

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "default.${local.cluster_name}.local"
  description = "Service discovery namespace.clustername.local"
  vpc         = module.vpc.vpc_id

  tags = var.tags
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_cloudwatch_log_group" "apigateway" {
  name              = "debug-apigateway"
  retention_in_days = var.cloudwatch_retention_in_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_retention_in_days

  tags = var.tags
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

data "aws_ssm_parameter" "mq" {
  name = "/mq/mq_application_password"
  
  depends_on = [
    module.mq
  ]
}

resource "aws_ssm_parameter" "mq_connection_uri" {
  name        = "/mq/mq_connection_uri"
  value       = format("amqps://%s:%s@%s", 
      module.mq.application_username,
      data.aws_ssm_parameter.mq.value,
      trimprefix(module.mq.primary_ssl_endpoint, "amqps://")
    )
  description = "AMQ connection uri"
  type        = "SecureString"
  key_id      = var.kms_ssm_key_arn
  overwrite   = var.overwrite_ssm_parameter

  tags        = var.tags
}
