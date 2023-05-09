variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = "eshop"
}

variable "name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "container_name" {
  type        = string
  default     = ""
  description = "description"
}

variable "container_port" {
  type        = number
  default     = 80
  description = "description"
}

variable "cluster_id" {
  description = "ID that identifies the cluster"
  type        = string
  default     = ""
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
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

variable "apigatewayv2_id" {
  type        = string
  description = "description"
  default = ""
}

variable "autoscaling_capacity_provider" {
  type        = string
  default     = ""
  description = "description"
}

variable "container_definitions" {
  type        = string
  default     = ""
  description = "description"
}

variable "alb_sg_security_group_id" {
  type        = string
  description = "description"
}

variable "cloudwatch_log_group_name" {
  type        = string
  default     = ""
  description = "description"
}

variable "cloudwatch_retention_in_days" {
  type        = number
  default     = 1
  description = "description"
}

variable "network_mode" {
  type        = string
  default     = "bridge"
  description = "description"
}

variable "service_cpu" {
  type        = number
  description = "description"
}

variable "service_memory" {
  type        = number
  description = "description"
}

variable "route_key" {
  type        = string
  default     = ""
  description = "description"
}
