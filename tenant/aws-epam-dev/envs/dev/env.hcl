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
    basket_api               = "http://basket-api.${local.domain}"
    ordering_api             = "http://ordering-api.${local.domain}"
    payment_api              = "http://payment-api.${local.domain}"
    ordering_signalrhub      = "http://ordering-signalrhub.${local.domain}"
    webshoppingagg           = "http://webshoppingagg.${local.domain}"
    mobileshoppingagg        = "http://mobileshoppingagg.${local.domain}"
    webhooks_api             = "http://webhooks-api.${local.domain}"
    webhooks_client          = "http://webhooks-client.${local.domain}"
    ordering_backgroundtasks = "http://ordering-backgroundtasks.${local.domain}"
  }

  discovery_services = {
    webspa                   = "http://webspa"
    webmvc                   = "http://webmvc"
    catalog_api              = "http://catalog-api"
    identity_api             = "http://identity-api"
    basket_api               = "http://basket-api"
    ordering_api             = "http://ordering-api"
    payment_api              = "http://payment-api"
    ordering_signalrhub      = "http://ordering-signalrhub"
    webshoppingagg           = "http://webshoppingagg"
    mobileshoppingagg        = "http://mobileshoppingagg"
    webhooks_api             = "http://webhooks-api"
    webhooks_client          = "http://webhooks-client"
    ordering_backgroundtasks = "http://ordering-backgroundtasks"
  }
}
