resource "aws_ecs_task_definition" "this" {
  family = var.name
  container_definitions = jsonencode([
    {
      name      = var.name
      image     = "${var.image}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
            awslogs-region = "eu-west-3",
            awslogs-group = "${var.aws_cloudwatch_log_group_name}",
            awslogs-stream-prefix = "ec2"
        }
      }
    }
  ])

  # Fargate configuration: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu = 512
  memory    = 1024
  network_mode = "awsvpc"

  execution_role_arn = "arn:aws:iam::326106872578:role/ecsTaskExecutionRole"

  runtime_platform {
    operating_system_family = "LINUX"
  }

  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1

  network_configuration {
    subnets = var.public_subnets
    security_groups = []
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.name
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [deployment_circuit_breaker, deployment_controller, capacity_provider_strategy]
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = var.lb_id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group" "this" {
  name = "ecs-tg-${var.name}"

  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  load_balancing_cross_zone_enabled = false
  deregistration_delay = 300
}
