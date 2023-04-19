variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "image" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "cluster_id" {
  description = "ID that identifies the cluster"
  type        = string
  default     = ""
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group"
  type        = list(string)
  default     = []
}

variable "aws_cloudwatch_log_group_name" {
  type        = string
  default     = ""
}
