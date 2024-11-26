
environment     = "nonprod"
subscription_id = "b7d2bd5f-b744-4acc-9c73-e068cec2e8d8"

vnets = {
  atlassian-int-nonprod-vnet = {
    name_override = "atlassian-int-nonprod-vnet"
    address_space = ["10.0.4.0/22"]
    subnets = {
      atlassian-int-subnet-ops = {
        name_override    = "atlassian-int-subnet-ops"
        address_prefixes = ["10.0.4.64/26"]
      }
      atlassian-int-subnet-dat = {
        name_override     = "atlassian-int-subnet-dat"
        address_prefixes  = ["10.0.4.128/26"]
        service_endpoints = ["Microsoft.Sql"]
      }
      atlassian-int-subnet-app = {
        name_override     = "atlassian-int-subnet-app"
        address_prefixes  = ["10.0.4.192/26"]
        service_endpoints = ["Microsoft.Sql"]
      }
    }
  }
  atlassian-dmz-nonprod-vnet = {
    name_override = "atlassian-dmz-nonprod-vnet"
    address_space = ["10.0.8.0/22"]
    subnets = {
      atlassian-dmz-subnet = {
        name_override     = "atlassian-dmz-subnet"
        address_prefixes  = ["10.0.8.0/28"]
        service_endpoints = ["Microsoft.Storage"]
        delegations = {
          app_delegation = {
            service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      }
      atlassian-dmz-subnet-appgw = {
        name_override    = "atlassian-dmz-subnet-appgw"
        address_prefixes = ["10.0.8.16/28"]
      }
    }
  }
}


network_security_groups = {
  atlassian-int-subnet-app-nsg = {
    subnets = ["atlassian-int-nonprod-vnet-atlassian-int-subnet-app"]
    rules = {
      "allow_atlassian-int-subnet-app" = {
        name_override              = "allow_atlassian-int-subnet-app"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "80", "443", "1099", "5432", "5701", "5801", "8005", "8080", "8090", "8091", "8095", "24007", "24008", "25500", "40001", "40011", "49152", "49153", "49154", "49155", "49156", "49157", "49158", "49159", "49160"]
        source_address_prefix      = "10.0.4.192/26"
        destination_address_prefix = "*"
      }
      "allow_atlassian-dmz-subnet" = {
        name_override              = "allow_atlassian-dmz-subnet"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "80", "443", "1099", "5432", "5701", "5801", "8005", "8080", "8090", "8091", "8095", "24007", "24008", "25500", "40001", "40011", "49152", "49153", "49154", "49155", "49156", "49157", "49158", "49159", "49160"]
        source_address_prefix      = "10.0.8.0/28"
        destination_address_prefix = "*"
      }
      "allow_atlassian-dmz-subnet-appgw" = {
        name_override              = "allow_atlassian-dmz-subnet-appgw"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["8080", "8090", "8095"]
        source_address_prefix      = "10.0.8.16/28"
        destination_address_prefix = "*"
      }
      "allow_atlassian-int-subnet-ops" = {
        name_override              = "allow_atlassian-int-subnet-ops"
        priority                   = 400
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "8080", "8090"]
        source_address_prefix      = "10.0.4.64/26"
        destination_address_prefix = "*"
      }
      "allow_any_AzureLoadBalancer" = {
        name_override              = "allow_any_AzureLoadBalancer"
        priority                   = 500
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      }
      "allow_vpn_ssh" = {
        name_override              = "allow_vpn_ssh"
        priority                   = 600
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.99.72.0/21"
        destination_address_prefix = "*"
      }
      "allow_mail_outbound" = {
        name_override              = "allow_mail_outbound"
        priority                   = 4010
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "2525"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
  atlassian-int-subnet-dat-nsg = {
    subnets = ["atlassian-int-nonprod-vnet-atlassian-int-subnet-dat"]
    rules = {
      "allow_atlassian-int-subnet-app" = {
        name_override              = "allow_atlassian-int-subnet-app"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "80", "443", "5432", "24007", "24008", "49152", "49153", "49154", "49155", "49156", "49157", "49158", "49159", "49160"]
        source_address_prefix      = "10.0.4.192/26"
        destination_address_prefix = "*"
      }
      "allow_atlassian-int-subnet-dat" = {
        name_override              = "allow_atlassian-int-subnet-dat"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "80", "443", "5432", "24007", "24008", "49152", "49153", "49154", "49155", "49156", "49157", "49158", "49159", "49160"]
        source_address_prefix      = "10.0.4.128/26"
        destination_address_prefix = "*"
      }
      "allow_atlassian-int-subnet-ops" = {
        name_override              = "allow_atlassian-int-subnet-ops"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "10.0.4.64/26"
        destination_address_prefix = "*"
      }
      "allow_any_AzureLoadBalancer" = {
        name_override              = "allow_any_AzureLoadBalancer"
        priority                   = 500
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      }
      "allow_vpn_ssh" = {
        name_override              = "allow_vpn_ssh"
        priority                   = 600
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.99.72.0/21"
        destination_address_prefix = "*"
      }
    }
  }
  atlassian-int-subnet-ops-nsg = {
    subnets = ["atlassian-int-nonprod-vnet-atlassian-int-subnet-ops"]
    rules = {
      "allow_crime_mgmt" = {
        name_override              = "allow_crime_mgmt"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.200.48.0/20"
        destination_address_prefix = "*"
      }
      "allow_atlassian-int-nonprod-vnet" = {
        name_override              = "allow_atlassian-int-nonprod-vnet"
        priority                   = 150
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.4.0/22"
        destination_address_prefix = "*"
      }
      "allow_crime_8834" = {
        name_override              = "allow_crime_8834"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8834"
        source_address_prefixes    = ["10.200.60.20", "10.200.48.32/27"]
        destination_address_prefix = "*"
      }
      "data_migration" = {
        name_override              = "data_migration"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "172.30.10.5"
        destination_address_prefix = "*"
      }
      "allow_1024-65535" = {
        name_override              = "allow_1024-65535"
        priority                   = 400
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "1024-65535"
        source_address_prefix      = "10.200.48.0/27"
        destination_address_prefix = "*"
      }
      "allow_any_AzureLoadBalancer" = {
        name_override              = "allow_any_AzureLoadBalancer"
        priority                   = 500
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      }
      "allow_29418" = {
        name_override              = "allow_29418"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "29418"
        source_address_prefix      = "*"
        destination_address_prefix = "10.88.128.192/27"
      }
    }
  }

  atlassian-dmz-subnet-nsg = {
    subnets = ["atlassian-dmz-nonprod-vnet-atlassian-dmz-subnet"]
    rules = {
      "allow_any" = {
        name_override              = "allow_any"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      "allow_outbound_atlassian-int-nonprod-vnet" = {
        name_override              = "allow_outbound_atlassian-int-nonprod-vnet"
        priority                   = 1000
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["443", "8080", "8090", "8095"]
        source_address_prefix      = "10.0.8.0/22"
        destination_address_prefix = "10.0.4.0/22"
      }
      "allow_outbound_any" = {
        name_override              = "allow_outbound_any"
        priority                   = 2000
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
}


backend_address_pools = [
  {
    name                      = "appgw-backend-pool-jira"
    backend_pool_ip_addresses = ["10.0.4.197", "10.0.4.198", "10.0.4.199"]
    backend_pool_fqdns        = []
  },
  {
    name                      = "appgw-backend-pool-crd"
    backend_pool_ip_addresses = ["10.0.4.202"]
    backend_pool_fqdns        = []
  },
  {
    name                      = "appgw-backend-pool-cnf"
    backend_pool_ip_addresses = ["10.0.4.200", "10.0.4.201"]
    backend_pool_fqdns        = []
  }
]

probes = [
  {
    name                                      = "appgw-probe-jira"
    interval                                  = 30
    path                                      = "/jira/status"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  },
  {
    name                                      = "appgw-probe-crd"
    interval                                  = 30
    path                                      = "/crowd"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  },
  {
    name                                      = "appgw-probe-cnf"
    interval                                  = 30
    path                                      = "/confluence"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }
]


backend_http_settings = [
  {
    name                                = "appgw-backend-settings-jira"
    probe_name                          = "appgw-probe-jira"
    cookie_based_affinity               = "Enabled"
    request_timeout                     = 300
    port                                = 8080
    pick_host_name_from_backend_address = true
    connection_draining = [{
      enabled           = true
      drain_timeout_sec = 15
    }, ]
  },
  {
    name                                = "appgw-backend-settings-crd"
    probe_name                          = "appgw-probe-crd"
    cookie_based_affinity               = "Enabled"
    request_timeout                     = 300
    port                                = 8095
    pick_host_name_from_backend_address = true
    connection_draining = [{
      enabled = false
    }]
  },
  {
    name                                = "appgw-backend-settings-cnf"
    probe_name                          = "appgw-probe-cnf"
    cookie_based_affinity               = "Enabled"
    request_timeout                     = 300
    port                                = 8090
    pick_host_name_from_backend_address = true
    connection_draining = [{
      enabled           = true
      drain_timeout_sec = 15
    }]
  }
]


http_listeners = [
  {
    name                 = "appgw-http-listener"
    ssl_enabled          = true
    ssl_certificate_name = "staging.tools.hmcts.net"
  }
]

request_routing_rules = [
  {
    name                       = "appgw-routing-rule"
    priority                   = 1
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-pool-cnf"
    backend_http_settings_name = "appgw-backend-settings-cnf"
  }
]

url_path_map = [
  {
    default_backend_address_pool_name  = "appgw-backend-pool-cnf"
    default_backend_http_settings_name = "appgw-backend-settings-cnf"
    path_rule = [
      {
        name                       = "confluence"
        paths                      = "/confluence*"
        backend_address_pool_name  = "appgw-backend-pool-cnf"
        backend_http_settings_name = "appgw-backend-settings-cnf"
      },
      {
        name                       = "crowd"
        paths                      = "/crowd*"
        backend_address_pool_name  = "appgw-backend-pool-crd"
        backend_http_settings_name = "appgw-backend-settings-crd"
      },
      {
        name                       = "jira"
        paths                      = "/jira*"
        backend_address_pool_name  = "appgw-backend-pool-jira"
        backend_http_settings_name = "appgw-backend-settings-jira"
      }
    ]
  }
]


ssl_certificates = [
  {
    name                = "staging.tools.hmcts.net"
    key_vault_secret_id = "https://acmedtssdsprod.vault.azure.net/secrets/wildcard-staging-tools-hmcts-net/00b6a6038e774bf891b11f910fc46a4d"
  }
]

enable_http2         = true
storage_account_name = "atlassiannonprod"
