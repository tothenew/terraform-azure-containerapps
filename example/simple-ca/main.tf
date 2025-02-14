provider "azurerm" {
  features {}
}

resource "random_id" "container_name" {
  byte_length = 1
}


locals {
  counting_app_name  = "counting-${random_id.container_name.hex}"
}

module "container_apps" {
  source                         = "../../" 
  tags = var.default_tags
  resource_group_name = var.resource_group_name
  location = var.location
  container_app_environment_name = "containerapp-test1"

  container_registry = null 

  container_apps = {
    counting = {
      name          = local.counting_app_name
      revision_mode = "Single"

      identity_ids = [
        "your_user_assigned_identity_id"
      ]

      template = {
        containers = [
          {
            name   = "countingservicetest1"
            memory = "0.5Gi"
            cpu    = 0.25
            image  = "docker.io/hashicorp/counting-service:0.0.2"
            env = [
              {
                name  = "PORT"
                value = "9001"
              }
            ]
          },
        ]
      }
    }
  }
}