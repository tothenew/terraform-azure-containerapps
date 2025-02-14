variable "location" {
  type        = string
  description = "(Required) The location this container app is deployed in. This should be the same as the environment in which it is deployed."
  nullable    = false
  default     = "Central India"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which the resources will be created."
  nullable    = false
  default     = "deepak"
}

variable "default_tags" {
  type        = map(string)
  description = "A map to add common tags to all the resources"
  default = {
    "CreatedBy"  : "TTN"
    "Module"    : "ContainerApp"
    "Managed-By" : "TTN"
  }
}
