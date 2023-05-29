variable "service" {
  description = "The name of the service"
  type        = string
  default     = "webspa"
}

variable "image" {
  description = "The name of the service"
  type        = string
  default     = "winshiftq/webspa:linux-terraform"
}
