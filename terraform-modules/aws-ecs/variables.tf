variable "app_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
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

################################################################################
# VPC
################################################################################

variable "create_vpc" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  type        = string
  default     = ""
  description = "description"
}

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

################################################################################
# ELB
################################################################################

variable "create_alb" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "load_balancer_name" {
  description = "The resource name and Name tag of the load balancer."
  type        = string
  default     = ""
}

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network."
  type        = string
  default     = "application"
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
# Supporting Resources
################################################################################

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#retention_in_days
variable "cloudwatch_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = string
  default     = 1
}
