variable "create_cluster" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "create_alb" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# ECS Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

################################################################################
# VPC
################################################################################

variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
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
