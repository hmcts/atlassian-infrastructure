variable "location" {
  description = "Azure resource location"
  default     = "uksouth"
  type        = string
}

variable "sku_name" {
  description = "name of the SKU to use for Application Gateway"
  default     = "WAF_v2"
}

variable "sku_tier" {
  description = "tier of the SKU to use for Application Gateway"
  default     = "WAF_v2"
}

variable "min_capacity" {
  default = 1
}

variable "max_capacity" {
  default = 2
}

variable "enable_waf" {
  default = true
}

variable "waf_mode" {
  description = "Mode for waf to run in"
  default     = "Prevention"
}

variable "enable_http2" {
  description = "Enable HTTP2? defaults to false"
  default     = false
  type        = bool
}

variable "autoShutdown" {
  description = "To add Tag for all the resources"
  default     = false
  type        = bool
}

variable "product" {
  description = "The name of the product."
  type        = string
  default     = "atlassian"
}

variable "builtFrom" {
  description = "The GitHub URL for the repository that contains the infrastructure code."
  type        = string
  default     = "hmcts/atlassian-infrastructure"
}

variable "waf_managed_rules" {
  type = list(object({
    type    = string
    version = string
    rule_group_override = list(object({
      rule_group_name = string
      rule = list(object({
        id      = string
        enabled = bool
        action  = string
      }))
    }))
  }))
  default = null
}

variable "waf_custom_rules" {
  type = list(object({
    name      = string
    priority  = number
    rule_type = string
    match_conditions = list(object({
      match_variables = list(object({
        variable_name = string
        selector      = optional(string)
      }))
      operator           = string
      negation_condition = bool
      match_values       = list(string)
    }))
    action = string
  }))
  default = null
}

variable "app_action" {
  description = "The action to take on the Jira VMs"
  type        = string
  default     = "status"
}

variable "enable_rewrite_rule_set" {
  description = "Flag to enable or disable the rewrite rule set"
  type        = bool
  default     = false
}
