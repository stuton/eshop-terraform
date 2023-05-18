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

output "aws_cloudwatch_log_group_name" {
  description = "The name of the log group. If omitted, Terraform will assign a random, unique name"
  value       = aws_cloudwatch_log_group.this.name
}

##################################################################
# RDS
##################################################################
// TODO if we don't create database, %s would be work
output "db_connection_string" {
  value       = var.create_database_instance ? format("Server=%s;User Id=%s;Password=%s;Encrypt=False;TrustServerCertificate=true", 
      replace(module.db.db_instance_endpoint, ":", ","), 
      module.db.db_instance_username,
      module.db.db_instance_password
    ) : ""
  sensitive   = true
}

##################################################################
# Amazon MQ
##################################################################

output "mq_connection_uri" {
  description = "AmazonMQ connection uri"
  value       = try(aws_ssm_parameter.mq_connection_uri.0.arn, "")
}

##################################################################
# Elasticache
##################################################################

output "elasticache_replication_group_primary_endpoint_address" {
  value = module.redis.elasticache_replication_group_primary_endpoint_address
}

output "elasticache_replication_group_reader_endpoint_address" {
  value       = module.redis.elasticache_replication_group_reader_endpoint_address
}
