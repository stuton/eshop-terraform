output "default_resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "default_resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "sql_server_admin_user" {
  description = "SQL database administrator login id"
  value       = module.mssql-server.sql_server_admin_user
  sensitive   = true
}

output "sql_server_admin_password" {
  description = "SQL database administrator login password"
  value       = module.mssql-server.sql_server_admin_password
  sensitive   = true
}

output "primary_sql_server_private_endpoint_ip" {
  description = "Primary SQL server private endpoint IPv4 Addresses "
  value       = module.mssql-server.primary_sql_server_private_endpoint_ip
}

output "primary_sql_server_private_endpoint_fqdn" {
  description = "Primary SQL server private endpoint IPv4 Addresses "
  value       = module.mssql-server.primary_sql_server_private_endpoint_fqdn
}
