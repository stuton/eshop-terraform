################################################################################
# Service
# https://github.com/terraform-aws-modules/terraform-aws-ecs/blob/master/variables.tf
# Fargate configuration: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
################################################################################

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.0"

  name        = var.name
  cluster_arn = data.aws_ecs_cluster.this.arn
  cpu    = var.service_cpu
  memory = var.service_memory
  network_mode = var.network_mode
  
  requires_compatibilities = ["EC2"]

  # service_registries = {
  #   registry_arn = aws_service_discovery_service.this.arn
  # }

  container_definitions = {
    (var.name) = jsondecode(var.container_definitions)
  }

  capacity_provider_strategy = {
    # On-demand instances
    default = {
      capacity_provider = var.autoscaling_capacity_provider
      weight            = 1
      base              = 1
    }
  }

  //assign_public_ip = true

  load_balancer = {
    service = {
      target_group_arn = element(module.service_alb.target_group_arns, 0)
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  subnet_ids = data.aws_subnets.public.ids

  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = var.alb_sg_security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}

##################################################################
# Application Load Balancer
# https://github.com/terraform-aws-modules/terraform-aws-alb/blob/master/variables.tf
##################################################################

module "service_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.3"

  name               = "${var.name}-alb"
  load_balancer_type = var.load_balancer_type

  vpc_id  = data.aws_vpc.this.id
  subnets = data.aws_subnets.public.ids
  
  security_groups = [var.alb_sg_security_group_id]

  http_tcp_listeners = [
    {
      port               = var.container_port
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name             = var.name
      backend_protocol = "HTTP"
      backend_port     = var.container_port
      health_check = {
        path      = "/"
        matcher   = "200-302"
        interval  = 30
      }
    },
  ]

  tags = var.tags
}

##################################################################
# API GATEWAY
##################################################################

resource "aws_apigatewayv2_integration" "this" {
  count            = var.apigatewayv2_id != "" ? 1 : 0
  api_id           = var.apigatewayv2_id
  description      = "Example with a load balancer"
  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri  = "http://${module.service_alb.lb_dns_name}"

  # connection_type    = "VPC_LINK"
  # connection_id      = var.apigatewayv2_vpc_link_id

  request_parameters = {
    "overwrite:path"    = "$request.path"
  }
}

resource "aws_apigatewayv2_route" "this" {
  count     = var.apigatewayv2_id != "" && var.route_key != "" ? 1 : 0
  api_id    = var.apigatewayv2_id
  route_key = var.route_key

  target = "integrations/${aws_apigatewayv2_integration.this[0].id}"
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_service_discovery_service" "this" {
  name = var.name

  dns_config {
    namespace_id = data.aws_service_discovery_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_retention_in_days

  tags = var.tags
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["eshop-*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["eshop-vpc-public-*"]
  }
}

data "aws_ecs_cluster" "this" {
  cluster_name = "${var.cluster_name}-ecs"
}

data "aws_service_discovery_dns_namespace" "this" {
  name = "default.${data.aws_ecs_cluster.this.cluster_name}.local"
  type = "DNS_PRIVATE"
}
