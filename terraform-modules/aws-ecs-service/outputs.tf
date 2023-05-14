output "lb_dns_name" {
  value       = module.service_alb.lb_dns_name
  description = "description"
}

output "lb_zone_id" {
  value = module.service_alb.lb_zone_id
}
