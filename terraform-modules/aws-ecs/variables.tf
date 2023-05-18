variable "app_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "domain" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Key pair
################################################################################

variable "create_key_pair" {
  description = "Determines whether key_pair will be created"
  type        = bool
  default     = true
}

variable "create_private_key" {
  description = "Determines whether a private key will be created"
  type        = bool
  default     = true
}

################################################################################
# ECS Cluster
################################################################################
variable "create_cluster" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "autoscaling_min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = null
}

variable "autoscaling_max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = null
}

variable "autoscaling_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group"
  type        = number
  default     = null
}

################################################################################
# VPC
################################################################################

variable "create_vpc" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = "10.0.0.0/16"
}

################################################################################
# Amazon MQ
################################################################################
variable "create_mq" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "mq_broker_name" {
  type        = string
  default     = "eshop"
  description = "description"
}

variable "mq_engine_type" {
  type        = string
  description = "Type of broker engine, `ActiveMQ` or `RabbitMQ`"
  default     = "ActiveMQ"
}

variable "mq_engine_version" {
  type        = string
  description = "The version of the broker engine. See https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/broker-engine.html for more details"
  default     = "5.15.14"
}

variable "mq_host_instance_type" {
  type        = string
  description = "The broker's instance type. e.g. mq.t2.micro or mq.m4.large"
  default     = "mq.t3.micro"
}

variable "mq_deployment_mode" {
  type        = string
  description = "The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ"
  default     = "SINGLE_INSTANCE"
}

################################################################################
# RDS
################################################################################

variable "create_database_instance" {
  description = "Whether to create a database instance"
  type        = bool
  default     = true
}

variable "database_instance_name" {
  description = "The name of the RDS instance"
  type        = string
}

variable "database_custom_iam_instance_profile" {
  description = "RDS custom iam instance profile"
  type        = string
  default     = null
}

variable "database_allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = null
}

variable "database_storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (new generation of general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not. If you specify 'io1' or 'gp3' , you must also include a value for the 'iops' parameter"
  type        = string
  default     = null
}

variable "database_storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}

variable "database_engine" {
  description = "The database engine to use"
  type        = string
  default     = null
}

variable "database_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = null
}

variable "database_deletion_protection" {
  description = "The database can't be deleted when this value is set to true"
  type        = bool
  default     = false
}

variable "database_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = true
}

variable "database_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = null
}

variable "database_name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type        = string
  default     = null
}

variable "database_username" {
  description = "Username for the master DB user"
  type        = string
  default     = null
}

variable "database_port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}

variable "database_iam_database_authentication_enabled" {
  description = "Specifies whether or not the mappings of AWS Identity and Access Management (IAM) accounts to database accounts are enabled"
  type        = bool
  default     = false
}

variable "database_availability_zone" {
  description = "The Availability Zone of the RDS instance"
  type        = string
  default     = null
}

variable "database_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

# DB parameter group
variable "database_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = null
}

variable "database_parameters" {
  description = "A list of DB parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

# DB option group
variable "database_major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
  default     = null
}

variable "database_options" {
  description = "A list of Options to apply"
  type        = any
  default     = []
}

variable "database_publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "database_allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  type        = bool
  default     = false
}

variable "database_create_cloudwatch_log_group" {
  description = "Determines whether a CloudWatch log group is created for each `enabled_cloudwatch_logs_exports`"
  type        = bool
  default     = false
}

variable "database_enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)"
  type        = list(string)
  default     = []
}

variable "database_create_db_subnet_group" {
  description = "Whether to create a database subnet group"
  type        = bool
  default     = true
}

################################################################################
# Elasticache Redis
################################################################################

variable "redis_cluster_mode_enabled" {
  type        = bool
  description = "Enable creation of a native redis cluster."
  default     = false
}

variable "redis_num_cache_clusters" {
  type        = number
  default     = 1
  description = "The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2. Updates will occur before other modifications. Conflicts with num_node_groups."
}

variable "redis_engine_version" {
  default     = "6.x"
  type        = string
  description = "The version number of the cache engine to be used for the cache clusters in this replication group."
}

variable "redis_family" {
  default     = "redis6.x"
  type        = string
  description = "The family of the ElastiCache parameter group."
}

variable "redis_automatic_failover_enabled" {
  default     = true
  type        = bool
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If enabled, number_cache_clusters must be greater than 1. Must be enabled for Redis (cluster mode enabled) replication groups."
}

variable "redis_multi_az_enabled" {
  type        = bool
  description = "Specifies whether to enable Multi-AZ Support for the replication group. If true, `automatic_failover_enabled` must also be enabled. Defaults to false."
  default     = false
}

variable "redis_at_rest_encryption_enabled" {
  default     = false
  type        = bool
  description = "Whether to enable encryption at rest."
}

variable "redis_transit_encryption_enabled" {
  default     = false
  type        = bool
  description = "Whether to enable encryption in transit."
}

variable "redis_apply_immediately" {
  default     = false
  type        = bool
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window."
}

variable "redis_description" {
  default     = "Managed by Terraform"
  type        = string
  description = "The description of the all resources."
}

variable "redis_node_type" {
  default     = "cache.t2.micro"
  type        = string
  description = "The compute and memory capacity of the nodes in the node group."
}

variable "redis_auth_token" {
  description = "The password used to access a password protected server. Can be specified only if `transit_encryption_enabled = true`."
  type        = string
  default     = ""
}

variable "redis_cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  type        = string
}

variable "redis_cloudwatch_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = string
  default     = "1"
}

################################################################################
# Security Groups
################################################################################

variable "alb_sg_name" {
  type        = string
  default     = ""
  description = "description"
}

################################################################################
# Supporting Resources
################################################################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#retention_in_days
variable "cloudwatch_log_group_name" {
  type        = string
  description = "description"
}

variable "cloudwatch_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = string
  default     = "1"
}

variable "kms_ssm_key_arn" {
  type        = string
  description = "ARN of the AWS KMS key used for SSM encryption"
  default     = "alias/aws/ssm"
}

variable "overwrite_ssm_parameter" {
  type        = bool
  description = "Whether to overwrite an existing SSM parameter"
  default     = true
}

variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = true
}
