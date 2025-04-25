
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

variable "ss-env" {
  description = "vnet required for peering"
  type        = string
}

variable "ss-env-sub" {
  description = "subscription required for peering"
  type        = string
}



variable "vms" {
  description = "List of VMs to create"
  type = map(object({
    computer_name      = string
    vm_size            = string
    nic_name           = string
    os_disk_name       = optional(string)
    private_ip_address = string
    app                = string
    db_server          = optional(string, "null")
  }))
}

variable "data_disks" {
  description = "List of data disks to attach to VMs"
  type = map(object({
    vm_name              = string
    disk_size_gb         = number
    create_option        = string
    storage_account_type = string
    caching              = string
    lun                  = number
    source_resource_id   = optional(string)
    storage_account_id   = optional(string)
  }))
}

variable "nics" {
  description = "List of network interfaces to create"
  type = map(object({
    ip_configuration = map(object({
      name                  = string
      private_ip_allocation = string
      private_ip_address    = optional(string)
      subnet_name           = string
    }))
  }))
}

variable "env" {
  description = "Name of the environment set by the pipeline"
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

variable "backend_address_pools" {
  description = "list of backend pool"
  type = list(object({
    name                      = string
    backend_pool_ip_addresses = optional(list(string), [])
    backend_pool_fqdns        = optional(list(string), [])
  }))
}

variable "probes" {
  description = "List of probes"
  type = list(object({
    name                                      = string
    interval                                  = number
    path                                      = string
    timeout                                   = number
    unhealthy_threshold                       = number
    pick_host_name_from_backend_http_settings = bool
  }))
}


variable "backend_http_settings" {
  description = "List of backend pool settings"
  type = list(object({
    name                                = string
    probe_name                          = string
    cookie_based_affinity               = string
    affinity_cookie_name                = string
    request_timeout                     = number
    port                                = number
    pick_host_name_from_backend_address = bool
    connection_draining = list(object({
      enabled           = optional(bool, false)
      drain_timeout_sec = optional(number, 15)
    }))
  }))
}

variable "http_listeners" {
  description = "List of http listener"
  type = list(object({
    name                 = string
    ssl_enabled          = bool
    ssl_certificate_name = string
  }))
}

variable "request_routing_rules" {
  description = "List of routing rules"
  type = list(object({
    name                       = string
    priority                   = number
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
  }))
}

variable "url_path_map" {
  description = "List of url_path_map"
  type = list(object({
    default_backend_address_pool_name  = string
    default_backend_http_settings_name = string
    path_rule = list(object({
      name                       = string
      paths                      = string
      backend_address_pool_name  = string
      backend_http_settings_name = string
    }))
  }))
}

variable "ssl_certificates" {
  description = "SSL certificate list"
  type = list(object({
    name                = string
    key_vault_secret_id = string
  }))
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account"
}

variable "frontend_private_ip_address" {
  type        = string
  description = "Private IP address for the load balancer frontend"
}


variable "lb_backend_addresses" {
  type = map(object({
    name = optional(string)
    ip   = optional(string)
  }))
  description = "Map of backend addresses to add to the load balancer"
  default     = {}
}

variable "health_probes" {
  type = map(object({
    healthprobe_name  = string
    health_protocol   = string
    backend_port      = number
    lb_probe_interval = number
    protocol          = string
    frontend_port     = number
    backend_port_rule = number
    rule_name         = string
  }))
  description = "Map of health probes to add to the load balancer"
  default     = {}

}
