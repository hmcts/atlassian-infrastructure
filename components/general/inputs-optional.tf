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

