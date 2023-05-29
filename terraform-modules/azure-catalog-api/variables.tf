variable "service" {
  description = "The name of the service"
  type        = string
  default     = "catalog-api"
}

variable "image" {
  description = "The name of the service"
  type        = string
  default     = "winshiftq/catalog.api:linux-terraform"
}
