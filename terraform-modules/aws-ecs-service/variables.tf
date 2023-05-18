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

################################################################################
# ELB
################################################################################

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application or network."
  type        = string
  default     = "application"
}

variable "create_apigatewayv2_integration" {
  type        = bool
  default     = false
  description = "description"
}

variable "apigatewayv2_id" {
  type        = string
  description = "description"
  default     = ""
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
  default     = "awsvpc"
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

variable "health_check_path" {
  type        = string
  default     = "/hc"
  description = "description"
}

variable "create_distribution" {
  description = "Controls if CloudFront distribution should be created"
  type        = bool
  default     = false
}

variable "enabled_cloudfront" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100"
  type        = string
  default     = "PriceClass_100"
}

variable "domain" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}
