variable "create_api_gateway" {
  description = "Controls if API Gateway resources should be created"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the API"
  type        = string
  default     = ""
}

variable "description" {
  description = "The description of the API."
  type        = string
  default     = null
}

variable "create_api_domain_name" {
  description = "Whether to create API domain name resource"
  type        = bool
  default     = true
}

variable "domain" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "A subdomain name for which the certificate should be issued"
  type        = string
  default     = ""
}

variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "description"
  default     = "debug-apigateway"
}

variable "cloudwatch_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = string
  default     = "1"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
