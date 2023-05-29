output "container_address" {
  value       = azurerm_container_app.eshop-ca.ingress[0].fqdn
  description = "Incoming address of the service"
}
