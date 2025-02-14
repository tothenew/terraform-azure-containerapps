variable "container_app_environment_name" {
  type        = string
  description = "(Required) The name of the container apps managed environment. Changing this forces a new resource to be created."
  nullable    = false
}

variable "container_apps" {
  type = map(object({
    name                  = string
    tags                  = optional(map(string))
    revision_mode         = string
    workload_profile_name = optional(string)
    identity_ids        = list(string)

    template = object({
      containers = set(object({
        name    = string
        image   = string
        args    = optional(list(string))
        command = optional(list(string))
        cpu     = string
        memory  = string
        env = optional(set(object({
          name        = string
          secret_name = optional(string)
          value       = optional(string)
        })))
      }))
      max_replicas    = optional(number)
      min_replicas    = optional(number)
      revision_suffix = optional(string)
    })

    ingress = optional(object({
      allow_insecure_connections = optional(bool, false)
      external_enabled           = optional(bool, false)
      ip_security_restrictions = optional(list(object({
        action           = string
        ip_address_range = string
        name             = string
        description      = optional(string)
      })), [])
      target_port = number
      transport   = optional(string)
      traffic_weight = object({
        label           = optional(string)
        latest_revision = optional(string)
        revision_suffix = optional(string)
        percentage      = number
      })
    }))
    registry = optional(list(object({
      server               = string
      username             = optional(string)
      password_secret_name = optional(string)
      identity             = optional(string)
    })))

  }))
  description = "The container apps to deploy."
  nullable    = false

  validation {
    condition     = length(var.container_apps) >= 1
    error_message = "At least one container should be provided."
  }
  validation {
    condition     = alltrue([for n, c in var.container_apps : c.ingress == null ? true : (c.ingress.ip_security_restrictions == null ? true : (length(distinct([for r in c.ingress.ip_security_restrictions : r.action])) <= 1))])
    error_message = "The `action` types in an all `ip_security_restriction` blocks must be the same for the `ingress`, mixing `Allow` and `Deny` rules is not currently supported by the service."
  }
}

variable "location" {
  type        = string
  description = "(Required) The location this container app is deployed in. This should be the same as the environment in which it is deployed."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the resources will be created."
  nullable    = false
}

variable "container_app_environment" {
  type = object({
    name                = string
    resource_group_name = string
  })
  default     = null
  description = "Reference to existing container apps environment to use."
}

variable "container_app_environment_infrastructure_subnet_id" {
  type        = string
  default     = null
  description = "(Optional) The existing subnet to use for the container apps control plane. Changing this forces a new resource to be created."
}

variable "container_app_environment_internal_load_balancer_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Should the Container Environment operate in Internal Load Balancing Mode? Defaults to `false`. Changing this forces a new resource to be created."
}


variable "tags" {
  type    = map(string)
  default = {}
}


variable "container_registry" {
  type = object({
    name                = string
    resource_group_name = string
  })
  description = "Reference to existing container registery to use."
}


