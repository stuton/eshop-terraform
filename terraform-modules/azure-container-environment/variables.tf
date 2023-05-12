variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to be imported."
  nullable    = false
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

################################################################################
# VNET
################################################################################

variable "address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "The address space that is used by the virtual network."
}

variable "subnet_names" {
  type        = list(string)
  default     = ["subnet1", "subnet2", "subnet3"]
  description = "A list of public subnets inside the vNet."
}

variable "subnet_prefixes" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "The address prefix to use for the subnet."
}

variable "use_for_each" {
  type        = bool
  description = "Use `for_each` instead of `count` to create multiple resource instances."
  default     = true
}

variable "tags" {
  type = map(string)
  default = {}
  description = "The tags to associate with environment."
}

variable "vnet_name" {
  type        = string
  default     = "acctvnet"
  description = "Name of the vnet to create"
}

################################################################################
# MSSQL SERVER
################################################################################

variable "sqlserver_name" {
  description = "SQL server Name"
  default     = ""
}

variable "admin_username" {
  description = "The administrator login name for the new SQL Server"
  default     = null
}

variable "admin_password" {
  description = "The password associated with the admin_username user"
  default     = null
}

variable "database_name" {
  description = "The name of the database"
  default     = ""
}

variable "sql_database_edition" {
  description = "The edition of the database to be created"
  default     = "Standard"
}

variable "sqldb_service_objective_name" {
  description = " The service objective name for the database"
  default     = "S1"
}
