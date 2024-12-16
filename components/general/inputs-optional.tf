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
  default     = "Detection"
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

variable "install_azure_monitor" {
  description = "Install Azure Monitor Agent on VMs"
  default     = false
  type        = bool
}

variable "install_dynatrace_oneagent" {
  description = "Install Dynatrace OneAgent on VMs"
  default     = false
  type        = bool
}

variable "install_nessus_agent" {
  description = "Install Nessus Agent on VMs"
  default     = false
  type        = bool
}

variable "install_splunk_uf" {
  description = "Install Splunk Universal Forwarder on VMs"
  default     = false
  type        = bool
}
