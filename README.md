# Azure Container Apps Terraform Configuration

[![Lint Status](https://github.com/tothenew/terraform-aws-template/workflows/Lint/badge.svg)](https://github.com/tothenew/terraform-aws-template/actions)
[![LICENSE](https://img.shields.io/github/license/tothenew/terraform-aws-template)](https://github.com/tothenew/terraform-aws-template/blob/master/LICENSE)

This repository contains Terraform configurations for deploying and managing Azure Container Apps. The configurations are designed to be modular and reusable, allowing you to easily set up and manage your containerized applications on Azure.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Repository Structure

The repository is organized as follows:

- **.github**: Contains GitHub-specific configurations, such as workflows for CI/CD.
- **example**: Example configurations to help you get started.
   - **acr-ca**: Configuration for integrating Azure Container Registry (ACR) with Azure Container Apps.
   - **simple-ca**: Simplified configuration for deploying Azure Container Apps.
- **_local.tf**: Local variables and configurations.
- **_output.tf**: Outputs from the Terraform configurations.
- **_provider.tf**: Provider configurations for Azure.
- **_variable.tf**: Input variables for the Terraform configurations.
- **main.tf**: Main Terraform configuration file.
- **README.md**: This file, providing an overview of the repository.
- **versions.tf**: Specifies the versions of Terraform and providers.


### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
- An Azure account with the necessary permissions to create and manage resources.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/tothenew/terraform-azure-containerapps.git
   cd terraform-azure-containerapps
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan Terraform:
   ```bash
   terraform plan
   ```

4. Review and customize the variables in ```_variable.tf``` as needed.

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## example folder

The example folder contains practical examples to help you understand how to use the Terraform configurations in different scenarios.

## 1. **acr-ca**

- The **acr-ca** example demonstrates how to integrate Azure Container Registry (ACR) with Azure Container Apps. This is useful when you want to use a container registry to store and manage your container images.

- Key Features:
    - **Azure Container Registry Integration** : The example shows how to configure the **container_registry** input to use an existing ACR.

    - **Example Usage** :

```bash
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
  name                = "demo1264"
  resource_group_name = "Iman"
}

  container_apps = {
    counting = {
      name          = local.counting_app_name
      revision_mode = "Single"

      identity_ids = [
        "/subscriptions/75223151-1800-43db-a8f3-b7fe605d3385/resourceGroups/MC_Iman_Iman_centralindia/providers/Microsoft.ManagedIdentity/userAssignedIdentities/Iman-agentpool"
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

      registry = [
        {
          server   = "demo1264.azurecr.io"
          identity = "/subscriptions/75223151-1800-43db-a8f3-b7fe605d3385/resourceGroups/MC_gaurav_AZD-demo-cluster_centralindia/providers/Microsoft.ManagedIdentity/userAssignedIdentities/AZD-demo-cluster-agentpool"
        }
      ]

    }
  }
}
```

- **Steps to Run** : 
    1. Navigate to the acr-ca folder:
    ```bash
    cd example/acr-ca
    ```

    2. Initialize and apply the Terraform configuration:
    ```bash
    terraform init
    terraform apply
    ```



## 2. **simple-ca**
- The simple-ca example demonstrates a simplified deployment of Azure Container Apps without integrating with Azure Container Registry. This is useful for quick testing or when using public container images.
- Key Features:
    - **Simplified Deployment** : The example focuses on deploying a basic container app with minimal configuration.
    - **Public Image Deployment** : The container app uses a public container image from Docker Hub.

    - **Example Usage**:
```bash
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
        "/subscriptions/75223151-1800-43db-a8f3-b7fe605d3385/resourceGroups/MC_Iman_Iman_centralindia/providers/Microsoft.ManagedIdentity/userAssignedIdentities/Iman-agentpool"
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
```
- **Steps to Run** :
    1. Navigate to the simple-ca folder:
        ```bash
        cd example/simple-ca
        ```
    
    2. Initialize and apply the Terraform configuration:
        ```bash
        terraform init
        terraform apply
        ```


## Resources

The following resources are managed by this Terraform configuration:

- **azurerm_container_app_environment** : Manages the Azure Container App Environment.
- **azurerm_container_app** : Manages individual Azure Container Apps.
- **azurerm_container_registry** : Integrates with an existing Azure Container Registry.

## Inputs

The following input variables are required for the Terraform configuration:

- **resource_group_name** : The name of the Azure resource group where the resources will be deployed.
- **location** : The Azure region where the resources will be deployed.
- **tags** : A map of tags to apply to the resources.
- **container_app_environment_name** : The name of the Azure Container App Environment.
- **container_registry** : Configuration for the Azure Container Registry. Set to **null** if no registry is used.
- **container_apps** : A map of configurations for individual container apps. Each app has the following structure:
   - **name** : The name of the container app.
   - **revision_mode** : The revision mode for the container app **(e.g., **Single**)**.
   - **identity_ids** : A list of user-assigned managed identity IDs for the container app.
   - **template** : Configuration for the container app's template, including:
      - **containers** : A list of containers to run in the app, each with:
         - **name** : The name of the container.
         - **memory** : The memory allocation for the container.
         - **cpu** : The CPU allocation for the container.
         - **image** : The container image to use.
         - **env** : Environment variables for the container.
   

### Example Usage

Here’s an example of how to use the container_apps module with the required inputs:

```bash
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
        "/subscriptions/75223151-1800-43db-a8f3-b7fe605d3385/resourceGroups/MC_Iman_Iman_centralindia/providers/Microsoft.ManagedIdentity/userAssignedIdentities/Iman-agentpool"
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
          }
        ]
      }
    }
  }
}
```

## Outputs

The following outputs are provided by the Terraform configuration:

- **container_app_environment_ids** : The IDs of the created Azure Container App Environments.

- **container_app_fqdn** : The Fully Qualified Domain Name (FQDN) of the Container App's ingress.

- **container_app_identities** : The identities of the Container Apps, keyed by the app name.

- **container_app_ips** : The IPs of the latest revision of the Container App.

- **container_app_uri** : The URI of the Container App's ingress.

<!-- END_TF_DOCS -->

## Contributing

We welcome contributions! Please read our **CONTRIBUTING.md** file for details on how to submit pull requests and our **CODE_OF_CONDUCT.md** for community guidelines.

## Authors

Module managed by [TO THE NEW Pvt. Ltd.](https://github.com/tothenew)

## License

Apache 2 Licensed. See [LICENSE](https://github.com/tothenew/terraform-aws-template/blob/main/LICENSE) for full details.


This updated README provides a comprehensive overview of the repository, including detailed explanations of the acr-ca and simple-ca examples. It ensures that users can easily understand and use the provided Terraform configurations for different scenarios.
