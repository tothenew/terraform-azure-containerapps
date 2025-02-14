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

  container_registry = {
  name                = "your_repo_name"
  resource_group_name = "your_registry_resource_group_name"
}

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
            image  = "your_registry_image"
            env = [
              {
                name  = "PORT"
                value = "9001"
              }
            ]
          },
        ]
      }

      registry = [
        {
          server   = "demo1264.azurecr.io"
          identity = "your_user_assigned_identity_id"
        }
      ]

    }
  }
}