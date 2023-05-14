##################################################################
# GATEWAY API
##################################################################

output "apigatewayv2_id" {
  value       = module.api_gateway.apigatewayv2_api_id
  description = "description"
}

output "apigatewayv2_vpc_link_id" {
  value       = length(module.api_gateway.apigatewayv2_vpc_link_id) > 0 ? module.api_gateway.apigatewayv2_vpc_link_id["eshop"] : ""
  description = "description"
}

output "apigatewayv2_api_api_endpoint" {
  description = "The URI of the API"
  value       = module.api_gateway.apigatewayv2_api_api_endpoint
}
