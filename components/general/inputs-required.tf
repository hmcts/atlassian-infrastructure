
variable "vnets" {
  description = "Vnets required for atlassian infra"
  type = map(object({
    name_override = optional(string)
    address_space = optional(list(string))
    existing      = optional(bool, false)
    subnets = map(object({
      name_override     = optional(string)
      address_prefixes  = list(string)
      service_endpoints = optional(list(string), [])
      delegations = optional(map(object({
        service_name = string,
        actions      = optional(list(string), [])
      })))
    }))
  }))
}

variable "env" {
  description = "Name of the environment set by the pipeline"
  type        = string
}

variable "builtFrom" {
  description = "The GitHub URL for the repository that contains the infrastructure code."
  type        = string
}

variable "product" {
  description = "The name of the product."
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID where Azure resources going to be deployed"
  type        = string
}

variable "network_security_groups" {
  type = map(object({
    name_override           = optional(string)
    resource_group_override = optional(string)
    subnets                 = optional(list(string))
    deny_inbound            = optional(bool, true)
    rules = map(object({
      name_override                              = optional(string)
      priority                                   = number
      direction                                  = string
      access                                     = string
      protocol                                   = string
      source_port_range                          = optional(string)
      source_port_ranges                         = optional(list(string))
      destination_port_range                     = optional(string)
      destination_port_ranges                    = optional(list(string))
      source_address_prefix                      = optional(string)
      source_address_prefixes                    = optional(list(string))
      source_application_security_group_ids      = optional(list(string))
      destination_address_prefix                 = optional(string)
      destination_address_prefixes               = optional(list(string))
      destination_application_security_group_ids = optional(list(string))
      description                                = optional(string)
    }))
  }))
  description = "Map of network security groups to create."
  default     = {}
}
