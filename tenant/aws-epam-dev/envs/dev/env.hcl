locals {
  env_name   = "dev"
  account_id = "326106872578"
  aws_region = "eu-west-3"

  domain = "selfpower.shop"
  subdomains = {
    //api    = "api.${local.domain}"
    webspa                   = "http://webspa.${local.domain}"
    webmvc                   = "http://webmvc.${local.domain}"
    catalog_api              = "http://catalog-api.${local.domain}"
    identity_api             = "http://identity-api.${local.domain}"
    backet_api               = "http://basket-api.${local.domain}"
    ordering_api             = "http://ordering-api.${local.domain}"
    payment_api              = "http://payment-api.${local.domain}"
    ordering_signalrhub      = "http://ordering-signalrhub.${local.domain}"
    webshoppingagg           = "http://webshoppingagg.${local.domain}"
    mobileshoppingagg        = "http://mobileshoppingagg.${local.domain}"
    webhooks_api             = "http://webhooks-api.${local.domain}"
    webhooks_client          = "http://webhooks-client.${local.domain}"
    ordering_backgroundtasks = "http://ordering-backgroundtasks.${local.domain}"
  }

  discovery_service = "default.eshop-ecs.local"
  discovery_services = {
    webspa                   = "http://webspa.${local.discovery_service}"
    webmvc                   = "http://webmvc.${local.discovery_service}"
    catalog_api              = "http://catalog-api.${local.discovery_service}"
    identity_api             = "http://identity-api.${local.discovery_service}"
    backet_api               = "http://basket-api.${local.discovery_service}"
    ordering_api             = "http://ordering-api.${local.discovery_service}"
    payment_api              = "http://payment-api.${local.discovery_service}"
    ordering_signalrhub      = "http://ordering-signalrhub.${local.discovery_service}"
    webshoppingagg           = "http://webshoppingagg.${local.discovery_service}"
    mobileshoppingagg        = "http://mobileshoppingagg.${local.discovery_service}"
    webhooks_api             = "http://webhooks-api.${local.discovery_service}"
    webhooks_client          = "http://webhooks-client.${local.discovery_service}"
    ordering_backgroundtasks = "http://ordering-backgroundtasks.${local.discovery_service}"
  }
}
