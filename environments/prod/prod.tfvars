# empty
env             = "prod"
subscription_id = "79898897-729c-41a0-a5ca-53c764839d95"

vnets = {
  atlassian-int-prod-vnet = {
    name_override = "atlassian-int-prod-vnet"
    address_space = ["10.1.4.0/22"]
    subnets = {
      atlassian-int-subnet-ops = {
        name_override    = "atlassian-int-subnet-ops"
        address_prefixes = ["10.1.4.64/26"]
      }
      atlassian-int-subnet-dat = {
        name_override     = "atlassian-int-subnet-dat"
        address_prefixes  = ["10.1.4.128/26"]
        service_endpoints = ["Microsoft.Sql"]
      }
      atlassian-int-subnet-app = {
        name_override     = "atlassian-int-subnet-app"
        address_prefixes  = ["10.1.4.192/26"]
        service_endpoints = ["Microsoft.Sql"]
      }
      atlassian-int-subnet-postgres = {
        name_override     = "atlassian-int-subnet-postgres"
        address_prefixes  = ["10.1.4.0/26"]
        service_endpoints = ["Microsoft.Sql"]
      }
      atlassian-int-subnet-postgres-flex = {
        name_override    = "atlassian-int-subnet-postgres-flex"
        address_prefixes = ["10.1.5.0/28"]
        delegations = {
          flexibleserver = {
            service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      }
    }
  }
  atlassian-dmz-prod-vnet = {
    name_override = "atlassian-dmz-prod-vnet"
    address_space = ["10.1.8.0/22"]
    subnets = {
      atlassian-dmz-subnet = {
        name_override     = "atlassian-dmz-subnet"
        address_prefixes  = ["10.1.8.0/28"]
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
        address_prefixes = ["10.1.8.16/28"]
      }
    }
  }
}

ss-env     = "prod"
ss-env-sub = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c"


network_security_groups = {
  atlassian-int-subnet-app-nsg = {
    subnets = ["atlassian-int-prod-vnet-atlassian-int-subnet-app"]
    rules = {
      "allow_atlassian-int-subnet-app" = {
        name_override              = "allow_atlassian-int-subnet-app"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "80", "443", "1099", "5432", "5701", "5801", "8005", "8080", "8090", "8091", "8095", "24007", "24008", "25500", "40001", "40011", "49152", "49153", "49154", "49155", "49156", "49157", "49158", "49159", "49160"]
        source_address_prefix      = "10.1.4.192/26"
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
        source_address_prefix      = "10.1.8.0/28"
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
        source_address_prefix      = "10.1.8.16/28"
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
        source_address_prefix      = "10.1.4.64/26"
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
      "allow_aks_ssh" = {
        name_override              = "allow_aks_ssh"
        priority                   = 620
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["10.144.16.0/20", "10.144.0.0/20"]
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
      "postgres_private" = {
        name_override              = "postgres_private"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "10.1.4.0/26"
      }
      "postgres_flex_private" = {
        name_override              = "postgres_flex_private"
        priority                   = 150
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "10.1.5.0/28"
      }
      "postgres_outbound" = {
        name_override              = "postgres_outbound"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
  atlassian-int-subnet-dat-nsg = {
    subnets = ["atlassian-int-prod-vnet-atlassian-int-subnet-dat"]
    rules = {
      "allow_atlassian-int-subnet-app" = {
        name_override              = "allow_atlassian-int-subnet-app"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "80", "443", "5432", "24007", "24008", "49152", "49153", "49154", "49155", "49156", "49157", "49158", "49159", "49160"]
        source_address_prefix      = "10.1.4.192/26"
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
        source_address_prefix      = "10.1.4.128/26"
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
        source_address_prefix      = "10.1.4.64/26"
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
      "allow_aks_ssh" = {
        name_override              = "allow_aks_ssh"
        priority                   = 620
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["10.144.16.0/20", "10.144.0.0/20"]
        destination_address_prefix = "*"
      }
      "postgres_private" = {
        name_override              = "postgres_private"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "10.1.4.0/26"
      }
      "postgres_flex_private" = {
        name_override              = "postgres_flex_private"
        priority                   = 150
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "10.1.5.0/28"
      }
      "postgres_outbound" = {
        name_override              = "postgres_outbound"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
  atlassian-int-subnet-ops-nsg = {
    subnets = ["atlassian-int-prod-vnet-atlassian-int-subnet-ops"]
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
      "allow_atlassian-int-prod-vnet" = {
        name_override              = "allow_atlassian-int-prod-vnet"
        priority                   = 150
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.1.4.0/22"
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
      "postgres_private" = {
        name_override              = "postgres_private"
        priority                   = 150
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "10.1.4.0/26"
      }
      "postgres_flex_private" = {
        name_override              = "postgres_flex_private"
        priority                   = 160
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "10.1.5.0/28"
      }
      "postgres_outbound" = {
        name_override              = "postgres_outbound"
        priority                   = 200
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }

  atlassian-dmz-subnet-nsg = {
    subnets = ["atlassian-dmz-prod-vnet-atlassian-dmz-subnet"]
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
      "allow_outbound_atlassian-int-prod-vnet" = {
        name_override              = "allow_outbound_atlassian-int-prod-vnet"
        priority                   = 1000
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["443", "8080", "8090", "8095"]
        source_address_prefix      = "10.1.8.0/22"
        destination_address_prefix = "10.1.4.0/22"
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
    backend_pool_ip_addresses = ["10.1.4.196", "10.1.4.197", "10.1.4.198"]
    backend_pool_fqdns        = []
  },
  {
    name                      = "appgw-backend-pool-crd"
    backend_pool_ip_addresses = ["10.1.4.201"]
    backend_pool_fqdns        = []
  },
  {
    name                      = "appgw-backend-pool-cnf"
    backend_pool_ip_addresses = ["10.1.4.199", "10.1.4.200"]
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
    ssl_certificate_name = "prod-temp.tools.hmcts.net"
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
    name                = "prod-temp.tools.hmcts.net"
    key_vault_secret_id = "https://acmedtssdsprod.vault.azure.net/secrets/prod-temp-tools-hmcts-net/0bd3aa7f88c844a9bbd1f36843dc74ba"
  }
]

enable_http2         = true
storage_account_name = "atlassianprod"
autoShutdown         = false

vms = {
  atlassian-prod-jira-01 = {
    computer_name      = "prdatl01ajra01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-jira-01-nic-fa6deec7117648fc82e83da31a083a2d"
    os_disk_name       = "atlassianprodjira01-osdisk-20250226-170818"
    private_ip_address = "10.1.4.196"
    app                = "jira"
  }

  atlassian-prod-jira-02 = {
    computer_name      = "prdatl01ajra02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-jira-02-nic-b39b1d56680647e392d292169bdc103a"
    os_disk_name       = "atlassianprodjira02-osdisk-20250212-145428"
    private_ip_address = "10.1.4.197"
    app                = "jira"
  }

  atlassian-prod-jira-03 = {
    computer_name      = "prdatl01ajra03.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-jira-03-nic-f7610403fbc349e2911f962dda033772"
    os_disk_name       = "atlassianprodjira03-osdisk-20250212-145617"
    private_ip_address = "10.1.4.198"
    app                = "jira"
  }

  atlassian-prod-crowd-01 = {
    computer_name      = "prdatl01acrd01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E4s_v3"
    nic_name           = "atlassian-prod-crowd-01-nic-3361e72e986e41d6b5eb6a21cbbcd112"
    os_disk_name       = "atlassianprodcrowd01-osdisk-20250212-150223"
    private_ip_address = "10.1.4.201"
    app                = "crowd"
  }

  atlassian-prod-confluence-02 = {
    computer_name      = "prdatl01acnf02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-confluence-02-nic-5beb0ec997f04da6be7e9d937327ce20"
    os_disk_name       = "atlassianprodconfluence02-osdisk-20250212-150643"
    private_ip_address = "10.1.4.199"
    app                = "confluence"
  }

  atlassian-prod-confluence-04 = {
    computer_name      = "prdatl01acnf04.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-confluence-04-nic-8ba484c6cb594b3d90819fb0966a46f9"
    os_disk_name       = "atlassianprodconfluence04-osdisk-20250212-150702"
    private_ip_address = "10.1.4.200"
    app                = "confluence"
  }
  atlassian-prod-gluster-01 = {
    computer_name      = "prdatl01dgst01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-gluster-01-nic-e45cc4e490274206be27bf6edb146c83"
    os_disk_name       = "atlassianprodgluster01-osdisk-20250212-150320"
    private_ip_address = "10.1.4.132"
    app                = "gluster"
  }

  atlassian-prod-gluster-02 = {
    computer_name      = "prdatl01dgst02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-gluster-02-nic-35bec6dd7ccd4bbbb1b0393bd3ab92b1"
    os_disk_name       = "atlassianprodgluster02-osdisk-20250212-150340"
    private_ip_address = "10.1.4.133"
    app                = "gluster"
  }

  atlassian-prod-gluster-03 = {
    computer_name      = "prdatl01dgst03.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-gluster-03-nic-2d04cbd8ac8440a4a21334adcd93ab95"
    os_disk_name       = "atlassianprodgluster03-osdisk-20250212-150358"
    private_ip_address = "10.1.4.134"
    app                = "gluster"
  }
}

data_disks = {
  atlassianprodjira01-datadisk-000-20250226-170818 = {
    vm_name              = "atlassian-prod-jira-01"
    disk_size_gb         = 100
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01ajra01.cp.cjs.hmcts.net_8566286297458822223/restorePoints/AzureBackup_20250226_023503/disks/Temp?id=cbc2d318-a1b7-4e89-b9ef-419bef1d942f"
  }


  atlassianprodconfluence02-datadisk-000-20250212-150643 = {
    vm_name              = "atlassian-prod-confluence-02"
    disk_size_gb         = 128
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01acnf02.cp.cjs.hmcts.net_8566286296656763634/restorePoints/AzureBackup_20250212_023715/disks/VD-ATL01ACNF02-02-DATA?id=1e9255c6-17ce-46b4-9a1f-318a4e0dbc12"
  }

  atlassianprodconfluence04-datadisk-000-20250212-150702 = {
    vm_name              = "atlassian-prod-confluence-04"
    disk_size_gb         = 128
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01acnf04.cp.cjs.hmcts.net_8566286296174594913/restorePoints/AzureBackup_20250212_023645/disks/VD-ATL01ACNF04-02-DATA?id=65dddc20-2d76-47cb-a5d5-f63bfebedfe6"
  }

  atlassianprodgluster01-datadisk-000-20250212-150320 = {
    vm_name              = "atlassian-prod-gluster-01"
    disk_size_gb         = 4000
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01dgst01.cp.cjs.hmcts.net_8566286296963951295/restorePoints/AzureBackup_20250212_023302/disks/VD-PRD-ATL01DGST01-02-DATA?id=3852dcf1-a9f7-43cb-9f61-58db316319dc"
  }


  atlassianprodgluster01-datadisk-001-20250212-150320 = {
    vm_name              = "atlassian-prod-gluster-01"
    disk_size_gb         = 1024
    create_option        = "Restore"
    storage_account_type = "StandardSSD_LRS"
    lun                  = 1
    caching              = "None"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01dgst01.cp.cjs.hmcts.net_8566286296963951295/restorePoints/AzureBackup_20250212_023302/disks/VD-PRD-ATLJCC-01-WAL?id=54335017-d7cc-4ab2-a7bb-1d4cd12e2bd4"
  }


  atlassianprodgluster02-datadisk-000-20250212-150340 = {
    vm_name              = "atlassian-prod-gluster-02"
    disk_size_gb         = 4000
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01dgst02.cp.cjs.hmcts.net_8566286296193198296/restorePoints/AzureBackup_20250212_023455/disks/VD-PRD-ATL01DGST02-02-DATA?id=8b806186-1132-4af7-aec4-ba10dc6d6925"
  }


  atlassianprodgluster03-datadisk-000-20250212-150358 = {
    vm_name              = "atlassian-prod-gluster-03"
    disk_size_gb         = 4000
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01dgst03.cp.cjs.hmcts.net_8566286297280434440/restorePoints/AzureBackup_20250212_024015/disks/VD-PRD-ATL01DGST03-02-DATA?id=67448cae-59bb-4dbc-bd62-ae6b05be404b"
  }
}

nics = {
  atlassian-prod-jira-01-nic-fa6deec7117648fc82e83da31a083a2d = {
    ip_configuration = {
      primary = {
        name                  = "7e0736805c7e479db2cc1199a640d931"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.196"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-jira-02-nic-b39b1d56680647e392d292169bdc103a = {
    ip_configuration = {
      primary = {
        name                  = "c9c9a5b64f2a42f5bc758087db9cad22"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.197"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-jira-03-nic-f7610403fbc349e2911f962dda033772 = {
    ip_configuration = {
      primary = {
        name                  = "9c27e91327924f0c869e2c5be79771c7"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.198"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-crowd-01-nic-3361e72e986e41d6b5eb6a21cbbcd112 = {
    ip_configuration = {
      primary = {
        name                  = "87d25b169c5c45e6949531faacfc505b"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.201"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }

  }

  atlassian-prod-confluence-02-nic-5beb0ec997f04da6be7e9d937327ce20 = {
    ip_configuration = {
      primary = {
        name                  = "259e29b50e684373a1588e96ec4c14ed"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.199"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-confluence-04-nic-8ba484c6cb594b3d90819fb0966a46f9 = {
    ip_configuration = {
      primary = {
        name                  = "2962b1467cba4c7eb61310406a78473f"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.200"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-gluster-01-nic-e45cc4e490274206be27bf6edb146c83 = {
    ip_configuration = {
      primary = {
        name                  = "b4b4121007314a22b48b788692df2a12"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.132"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-dat"
      }
    }
  }

  atlassian-prod-gluster-02-nic-35bec6dd7ccd4bbbb1b0393bd3ab92b1 = {
    ip_configuration = {
      primary = {
        name                  = "f385dc90c5a7494ca49ef799471455ae"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.133"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-dat"
      }
    }
  }

  atlassian-prod-gluster-03-nic-2d04cbd8ac8440a4a21334adcd93ab95 = {
    ip_configuration = {
      primary = {
        name                  = "389f654c117346ab908f499cc9a35140"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.134"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-dat"
      }
    }
  }
}



frontend_private_ip_address = "10.1.4.150"

lb_backend_addresses = {
  lb_address_1 = {
    name = "atlassian-prod-gluster-01"
    ip   = "10.1.4.132"
  }
  lb_address_2 = {
    name = "atlassian-prod-gluster-02"
    ip   = "10.1.4.133"
  }
  lb_address_3 = {
    name = "atlassian-prod-gluster-03"
    ip   = "10.1.4.134"
  }
}

health_probes = {
  24008 = {
    healthprobe_name  = "24008"
    health_protocol   = "Tcp"
    backend_port      = 24008
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 24008
    backend_port_rule = 24008
    rule_name         = "24008_GLUSTER_TCP-RULE"
  }
  8080 = {
    healthprobe_name  = "8080"
    health_protocol   = "Tcp"
    backend_port      = 8080
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 8080
    backend_port_rule = 8080
    rule_name         = "8080_GLUSTER_TCP-RULE"
  }
  24007 = {
    healthprobe_name  = "24007"
    health_protocol   = "Tcp"
    backend_port      = 24007
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 24007
    backend_port_rule = 24007
    rule_name         = "24007_GLUSTER_TCP-RULE"
  }
  443 = {
    healthprobe_name  = "443"
    health_protocol   = "Tcp"
    backend_port      = 443
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 443
    backend_port_rule = 443
    rule_name         = "443_GLUSTER_TCP-RULE"
  }
  40001 = {
    healthprobe_name  = "40001"
    health_protocol   = "Tcp"
    backend_port      = 40001
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 40001
    backend_port_rule = 40001
    rule_name         = "40001_GLUSTER_TCP-RULE"
  }

  49153 = {
    healthprobe_name  = "49153"
    health_protocol   = "Tcp"
    backend_port      = 49153
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 49153
    backend_port_rule = 49153
    rule_name         = "49153_GLUSTER_TCP-RULE"
  }
  8091 = {
    healthprobe_name  = "8091"
    health_protocol   = "Tcp"
    backend_port      = 8091
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 8091
    backend_port_rule = 8091
    rule_name         = "8091_GLUSTER_TCP-RULE"
  }
  80 = {
    healthprobe_name  = "80"
    health_protocol   = "Tcp"
    backend_port      = 80
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 80
    backend_port_rule = 80
    rule_name         = "80_GLUSTER_TCP-RULE"
  }
  8090 = {
    healthprobe_name  = "8090"
    health_protocol   = "Tcp"
    backend_port      = 8090
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 8090
    backend_port_rule = 8090
    rule_name         = "8090_GLUSTER_TCP-RULE"
  }

  49152 = {
    healthprobe_name  = "49152"
    health_protocol   = "Tcp"
    backend_port      = 49152
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 49152
    backend_port_rule = 49152
    rule_name         = "49152_GLUSTER_TCP-RULE"
  }
  1099 = {
    healthprobe_name  = "1099"
    health_protocol   = "Tcp"
    backend_port      = 1099
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 1099
    backend_port_rule = 1099
    rule_name         = "1099_GLUSTER_TCP-RULE"
  }
  8005 = {
    healthprobe_name  = "8005"
    health_protocol   = "Tcp"
    backend_port      = 8005
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 8005
    backend_port_rule = 8005
    rule_name         = "8005_GLUSTER_TCP-RULE"
  }
  8095 = {
    healthprobe_name  = "8095"
    health_protocol   = "Tcp"
    backend_port      = 8095
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 8095
    backend_port_rule = 8095
    rule_name         = "8095_GLUSTER_TCP-RULE"
  }
  5432 = {
    healthprobe_name  = "5432"
    health_protocol   = "Tcp"
    backend_port      = 5432
    lb_probe_interval = 15
    protocol          = "Tcp"
    frontend_port     = 5432
    backend_port_rule = 5432
    rule_name         = "5432_GLUSTER_TCP-RULE"
  }
}


# WAF Managed Rules
waf_managed_rules = [
  {
    type    = "OWASP"
    version = "3.2"
    rule_group_override = [
      {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rule = [
          {
            id      = "920300"
            enabled = true
            action  = "Log"
          },
          {
            id      = "920440"
            enabled = true
            action  = "Block"
          }
        ]
      }
    ]
  }
]

# WAF Custom Rules
waf_custom_rules = [
  {
    name      = "JiraException"
    priority  = 1
    rule_type = "MatchRule"
    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "RequestUri"
          }
        ]
        operator           = "Regex"
        negation_condition = false
        match_values       = ["\\/jira\\/(?:[^login\\.jsp\\W]).*"]
      }
    ]
    action = "Allow"
  },
  {
    name      = "Comments"
    priority  = 2
    rule_type = "MatchRule"
    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "RequestUri"
          }
        ]
        operator           = "Regex"
        negation_condition = false
        match_values       = ["[comment]"]
      }
    ]
    action = "Allow"
  },
  {
    name      = "TechPod"
    priority  = 10
    rule_type = "MatchRule"
    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "QueryString"
          }
        ]
        operator           = "Contains"
        negation_condition = false
        match_values       = ["?src=spacemenu"]
      }
    ]
    action = "Allow"
  },
  {
    name      = "JsonBulkPayLoad"
    priority  = 11
    rule_type = "MatchRule"
    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "PostArgs",
            selector      = "batch.js?locale=en-GB"
          }
        ]
        operator           = "Contains"
        negation_condition = false
        match_values       = ["POST"]
      }
    ]
    action = "Allow"
  },
  {
    name      = "Confluence"
    priority  = 12
    rule_type = "MatchRule"
    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "RequestUri"
          }
        ]
        operator           = "Contains"
        negation_condition = false
        match_values       = ["cql="]
      }
    ]
    action = "Allow"
  },
  {
    name      = "ConfluenceStatusURLAllow"
    priority  = 13
    rule_type = "MatchRule"
    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "RequestUri"
          }
        ]
        operator           = "Contains"
        negation_condition = false
        match_values       = ["status="]
      }
    ]
    action = "Allow"
  },
  {
    name      = "ConfluenceBulk"
    priority  = 14
    rule_type = "MatchRule"
    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "RequestUri"
          }
        ]
        operator           = "Contains"
        negation_condition = false
        match_values       = ["/rest/analytics/", "plugins/servlet/gadgets"]
      }
    ]
    action = "Allow"
  },
  {
    name      = "PlusSymbol"
    priority  = 15
    rule_type = "MatchRule"
    match_conditions = [
      {
        match_variables = [
          {
            variable_name = "RequestUri"
          }
        ]
        operator           = "Regex"
        negation_condition = false
        match_values       = ["[+]"]
      }
    ]
    action = "Allow"
  }
]

app_action = "status" # change this to "status" or "stop" in order to stop the jira

app_gw_rewrite_rules = [
  {
    ruleset_name  = "Prod-Rewrites"
    name          = "robots.txt"
    rule_sequence = 100
    condition = {
      variable    = "var_uri_path"
      pattern     = "/robots.txt"
      ignore_case = true
      negate      = false
    }
    response_header_configuration = {
      header_name  = "Content-Type"
      header_value = "text/plain"
    }
    url = {
      components = "path_only"
      path       = "/jira/robots.txt"
      reroute    = true
    }
  }
]


