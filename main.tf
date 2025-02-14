locals {
  container_app_environment_default_domain    = try(data.azurerm_container_app_environment.container_env[0].default_domain, azurerm_container_app_environment.container_env[0].default_domain)
  container_app_environment_id                = try(data.azurerm_container_app_environment.container_env[0].id, azurerm_container_app_environment.container_env[0].id)
  container_app_environment_static_ip_address = try(azurerm_container_app_environment.container_env[0].static_ip_address, data.azurerm_container_app_environment.container_env[0].static_ip_address)
  acr_login_server                            = var.container_registry != null ? data.azurerm_container_registry.existing_acr[0].login_server : null
}

data "azurerm_container_app_environment" "container_env" {
  count = var.container_app_environment != null ? 1 : 0

  name                = var.container_app_environment.name
  resource_group_name = var.container_app_environment.resource_group_name
}

data "azurerm_container_registry" "existing_acr" {
  count = var.container_registry != null ? 1 : 0
  name                = var.container_registry.name
  resource_group_name = var.container_registry.resource_group_name
}

resource "azurerm_container_app_environment" "container_env" {
  count = var.container_app_environment == null ? 1 : 0

  location                       = var.location
  name                           = var.container_app_environment_name
  resource_group_name            = var.resource_group_name
  infrastructure_subnet_id       = var.container_app_environment_infrastructure_subnet_id
  internal_load_balancer_enabled = var.container_app_environment_internal_load_balancer_enabled
  workload_profile {
    name = "Consumption"
    workload_profile_type = "Consumption"
  }
  tags = var.tags
  
}

resource "azurerm_container_app" "container_app" {
  for_each = var.container_apps

  container_app_environment_id = local.container_app_environment_id
  name                         = each.value.name
  resource_group_name          = var.resource_group_name
  revision_mode                = each.value.revision_mode
  tags = var.tags
  workload_profile_name = each.value.workload_profile_name

  identity {
    type         = "UserAssigned"
    identity_ids = each.value.identity_ids 
  }

  template {
    max_replicas    = each.value.template.max_replicas
    min_replicas    = each.value.template.min_replicas
    revision_suffix = each.value.template.revision_suffix

    dynamic "container" {
      for_each = each.value.template.containers

      content {
        cpu     = container.value.cpu
        image   = container.value.image
        memory  = container.value.memory
        name    = container.value.name
        args    = container.value.args
        command = container.value.command

        dynamic "env" {
          for_each = container.value.env == null ? [] : container.value.env

          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }
      }
    }
  }
  dynamic "ingress" {
    for_each = each.value.ingress == null ? [] : [each.value.ingress]

    content {
      target_port                = ingress.value.target_port
      allow_insecure_connections = ingress.value.allow_insecure_connections
      external_enabled           = ingress.value.external_enabled
      transport                  = ingress.value.transport

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight == null ? [] : [ingress.value.traffic_weight]

        content {
          percentage      = traffic_weight.value.percentage
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
        }
      }
      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restrictions == null ? [] : ingress.value.ip_security_restrictions

        content {
          action           = ip_security_restriction.value.action
          ip_address_range = ip_security_restriction.value.ip_address_range
          name             = ip_security_restriction.value.name
          description      = ip_security_restriction.value.description
        }
      }
    }
  }
  dynamic "registry" {
    for_each = each.value.registry == null ? [] : each.value.registry

    content {
      server               = registry.value.server
      identity             = registry.value.identity
      password_secret_name = registry.value.password_secret_name
      username             = registry.value.username
    }
  }
}
