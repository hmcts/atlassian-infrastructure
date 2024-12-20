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

variable "disabled_rule_groups" {
  description = "List of disabled rule groups for WAF"
  type = list(object({
    rule_group_name = string
    rules           = list(number)
  }))
  default = []
}
