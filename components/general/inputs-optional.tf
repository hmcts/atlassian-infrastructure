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

variable "app_gw_rewrite_rules" {
  description = "List of rewrite rules"
  type = list(object({
    ruleset_name  = string
    name          = string
    rule_sequence = number
    condition = object({
      variable    = string
      pattern     = string
      ignore_case = bool
      negate      = bool
    })
    response_header_configuration = object({
      header_name  = string
      header_value = string
    })
    url = object({
      components = string
      path       = string
      reroute    = bool
    })
  }))
  default = []
}

variable "flex_server_sku_name" {
  description = "The SKU name for the PostgreSQL Flexible Server"
  default     = "MO_Standard_E8s_v3"
}

variable "flex_server_storage_mb" {
  description = "The max storage allowed for the PostgreSQL Flexible Server"
  default     = 262144
}

variable "flex_server_storage_tier" {
  description = "The storage tier for the PostgreSQL Flexible Server"
  default     = "P15"
}

variable "flex_server_backup_retention_days" {
  description = "The number of days to retain backups for the PostgreSQL Flexible Server"
  default     = 7
}

variable "flex_server_geo_redundant_backups" {
  description = "Enable geo-redundant backups for the PostgreSQL Flexible Server"
  default     = false
}

variable "azure_monitor_settings" {
  description = "The settings passed to the Azure Monitor extension, these are specified as a JSON object in a string."
  type        = string
  default     = null
}

variable "install_dynatrace_oneagent" {
  type    = bool
  default = false
}

variable "install_azure_monitor" {
  type    = bool
  default = false
}

variable "install_nessus_agent" {
  type    = bool
  default = false
}

variable "install_splunk_uf" {
  type    = bool
  default = false
}

variable "install_endpoint_protection" {
  type    = bool
  default = false
}

variable "run_command" {
  type    = bool
  default = false
}

variable "os_type" {
  type    = string
  default = "linux"
}

variable "dynatrace_hostgroup" {
  type    = string
  default = null
}