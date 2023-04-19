output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs.cluster_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "lb_id" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.lb_id
}

output "aws_cloudwatch_log_group_name" {
  description = "The name of the log group. If omitted, Terraform will assign a random, unique name"
  value       = aws_cloudwatch_log_group.this.name
}
