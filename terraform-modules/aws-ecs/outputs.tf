output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs.cluster_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_sg_security_group_id" {
  value       = module.alb_sg.security_group_id
  description = "description"
}

output "aws_cloudwatch_log_group_name" {
  description = "The name of the log group. If omitted, Terraform will assign a random, unique name"
  value       = aws_cloudwatch_log_group.this.name
}

output "autoscaling_capacity_providers" {
  description = "Map of autoscaling capacity providers created and their attributes"
  value       = module.ecs.autoscaling_capacity_providers
}

##################################################################
# RDS
##################################################################

output "db_connection_string" {
  value       = format("Server=%s;User Id=%s;Password=%s;Encrypt=False;TrustServerCertificate=true", 
      replace(module.db.db_instance_endpoint, ":", ","), 
      module.db.db_instance_username,
      module.db.db_instance_password
    )
  sensitive   = true
}

##################################################################
# Amazon MQ
##################################################################

output "mq_connection_uri" {
  description = "AmazonMQ connection uri"
  value       = aws_ssm_parameter.mq_connection_uri.arn
}

##################################################################
# GATEWAY API
##################################################################

output "apigatewayv2_id" {
  value       = module.api_gateway.apigatewayv2_api_id
  description = "description"
}

output "apigatewayv2_vpc_link_id" {
  value       = length(module.api_gateway.apigatewayv2_vpc_link_id) > 0 ? module.api_gateway.apigatewayv2_vpc_link_id["eshop"] : ""
  description = "description"
}

output "apigatewayv2_api_api_endpoint" {
  description = "The URI of the API"
  value       = module.api_gateway.apigatewayv2_api_api_endpoint
}
