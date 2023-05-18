##################################################################
# GATEWAY API
##################################################################

output "apigatewayv2_id" {
  value       = module.api_gateway.apigatewayv2_api_id
  description = "The API identifier"
}

output "apigatewayv2_vpc_link_id" {
  value       = try(module.api_gateway.apigatewayv2_vpc_link_id[var.name], "")
  description = "The map of VPC Link identifiers"
}

output "apigatewayv2_api_api_endpoint" {
  value       = module.api_gateway.apigatewayv2_api_api_endpoint
  description = "The URI of the API"
}

output "availability_zone_subnets" {
  value = local.availability_zone_subnets
}
