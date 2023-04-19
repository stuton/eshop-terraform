data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

#########################################
# ECS Cluster
#########################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.3"

  create = var.create_cluster

  cluster_name = var.cluster_name

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

  name = var.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

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

  name = var.cluster_name

  load_balancer_type = "application"

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

  http_tcp_listeners = [
    # Forward action is default, either when defined or undefined
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      # action_type        = "forward"
    },
    # {
    #   port        = 81
    #   protocol    = "HTTP"
    #   action_type = "forward"
    #   forward = {
    #     target_groups = [
    #       {
    #         target_group_index = 0
    #         weight             = 100
    #       },
    #       {
    #         target_group_index = 1
    #         weight             = 0
    #       }
    #     ]
    #   }
    # },
    # {
    #   port        = 82
    #   protocol    = "HTTP"
    #   action_type = "redirect"
    #   redirect = {
    #     port        = "443"
    #     protocol    = "HTTPS"
    #     status_code = "HTTP_301"
    #   }
    # },
    # {
    #   port        = 83
    #   protocol    = "HTTP"
    #   action_type = "fixed-response"
    #   fixed_response = {
    #     content_type = "text/plain"
    #     message_body = "Fixed message"
    #     status_code  = "200"
    #   }
    # },
  ]

  target_groups = [
    {
      name_prefix                       = "ecs-"
      backend_protocol                  = "HTTP"
      backend_port                      = 80
      target_type                       = "ip"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = false
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      //tags = var.tags
    },
    # {
    #   name_prefix                        = "l1-"
    #   target_type                        = "lambda"
    #   lambda_multi_value_headers_enabled = true
    #   targets = {
    #     lambda_with_allowed_triggers = {
    #       target_id = module.lambda_with_allowed_triggers.lambda_function_arn
    #     }
    #   }
    # },
    # {
    #   name_prefix = "l2-"
    #   target_type = "lambda"
    #   targets = {
    #     lambda_without_allowed_triggers = {
    #       target_id                = module.lambda_without_allowed_triggers.lambda_function_arn
    #       attach_lambda_permission = true
    #     }
    #   }
    # },
  ]

  //tags = var.tags

}



################################################################################
# Supporting Resources
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${var.cluster_name}"
  retention_in_days = var.cloudwatch_retention_in_days

  tags = var.tags
}
