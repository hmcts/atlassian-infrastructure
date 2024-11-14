
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
