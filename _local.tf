locals {
  fqdns                  = { for name, container in azurerm_container_app.container_app : name => try(container.ingress[0].fqdn, "") if can(container.ingress[0].fqdn) }
  uris                   = { for name, fqdn in local.fqdns : name => "https://${fqdn}" }
}


