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
    backend_pool_ip_addresses = ["10.1.4.199"]
    backend_pool_fqdns        = []
  },
  {
    name                      = "appgw-backend-pool-cnf"
    backend_pool_ip_addresses = ["10.1.4.200", "10.1.4.201"]
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
    ssl_certificate_name = "tools.hmcts.net"
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
    name                = "tools.hmcts.net"
    key_vault_secret_id = "https://acmedtssdsprod.vault.azure.net/secrets/tools-hmcts-net"
  }
]

enable_http2         = true
storage_account_name = "atlassianprod"
autoShutdown         = false

vms = {
  atlassian-prod-jira-01 = {
    computer_name      = "prdatl01ajra01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-jira-01-nic-0fad0fe6e8d94210be9488435aa28b09"
    os_disk_name       = "atlassianprodjira01-osdisk-20250228-220516"
    private_ip_address = "10.1.4.196"
    app                = "jira"
  }

  atlassian-prod-jira-02 = {
    computer_name      = "prdatl01ajra02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-jira-02-nic-b0cfdcf4e4de498ea2a5bc53c79cfeed"
    os_disk_name       = "atlassianprodjira02-osdisk-20250228-220712"
    private_ip_address = "10.1.4.197"
    app                = "jira"
  }

  atlassian-prod-jira-03 = {
    computer_name      = "prdatl01ajra03.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-jira-03-nic-4b4dcb7535b74ab79a40c21ae805c7d0"
    os_disk_name       = "atlassianprodjira03-osdisk-20250228-220737"
    private_ip_address = "10.1.4.198"
    app                = "jira"
  }

  atlassian-prod-crowd-01 = {
    computer_name      = "prdatl01acrd01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E4s_v3"
    nic_name           = "atlassian-prod-crowd-01-nic-b4d13bce7fa44641a6a44c8f191ddc25"
    os_disk_name       = "atlassianprodcrowd01-osdisk-20250228-220949"
    private_ip_address = "10.1.4.199"
    app                = "crowd"
  }

  atlassian-prod-confluence-02 = {
    computer_name      = "prdatl01acnf02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-confluence-02-nic-c76f35248e73463ba673913dbd6e2a56"
    os_disk_name       = "atlassianprodconfluence02-osdisk-20250228-221025"
    private_ip_address = "10.1.4.200"
    app                = "confluence"
  }

  atlassian-prod-confluence-04 = {
    computer_name      = "prdatl01acnf04.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-confluence-04-nic-fe70ffff677e4b70b231293c054a5914"
    os_disk_name       = "atlassianprodconfluence04-osdisk-20250228-221041"
    private_ip_address = "10.1.4.201"
    app                = "confluence"
  }
  atlassian-prod-gluster-01 = {
    computer_name      = "prdatl01dgst01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-gluster-01-nic-1c8cb6fa1a7a488db7cb7a70c181164f"
    os_disk_name       = "atlassianprodgluster01-osdisk-20250228-221117"
    private_ip_address = "10.1.4.132"
    app                = "gluster"
  }

  atlassian-prod-gluster-02 = {
    computer_name      = "prdatl01dgst02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-gluster-02-nic-cd44e7ead6654137a23f3daefc5f00f6"
    os_disk_name       = "atlassianprodgluster02-osdisk-20250228-221141"
    private_ip_address = "10.1.4.133"
    app                = "gluster"
  }

  atlassian-prod-gluster-03 = {
    computer_name      = "prdatl01dgst03.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-prod-gluster-03-nic-33273cfe1f254cc5819f2639fc68cc3d"
    os_disk_name       = "atlassianprodgluster03-osdisk-20250228-221204"
    private_ip_address = "10.1.4.134"
    app                = "gluster"
  }
}

data_disks = {
  atlassianprodjira01-datadisk-000-20250228-220516 = {
    vm_name              = "atlassian-prod-jira-01"
    disk_size_gb         = 100
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01ajra01.cp.cjs.hmcts.net_8566286297458822223/restorePoints/AzureBackup_20250228_053608/disks/Temp?id=3a85bb24-e859-4e79-8b72-6a5dbf00d3ec"
  }

  atlassianprodconfluence02-datadisk-000-20250228-221025 = {
    vm_name              = "atlassian-prod-confluence-02"
    disk_size_gb         = 128
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01acnf02.cp.cjs.hmcts.net_8566286296656763634/restorePoints/AzureBackup_20250228_053507/disks/VD-ATL01ACNF02-02-DATA?id=b65ee2bd-fe6f-469b-a6ea-39b4c5fe6c38"
  }

  atlassianprodconfluence04-datadisk-000-20250228-221041 = {
    vm_name              = "atlassian-prod-confluence-04"
    disk_size_gb         = 128
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01acnf04.cp.cjs.hmcts.net_8566286296174594913/restorePoints/AzureBackup_20250228_053522/disks/VD-ATL01ACNF04-02-DATA?id=f68ef3ee-ec61-4387-b54a-0aeb3fb56d1b"
  }

  atlassianprodgluster01-datadisk-000-20250228-221117 = {
    vm_name              = "atlassian-prod-gluster-01"
    disk_size_gb         = 4000
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01dgst01.cp.cjs.hmcts.net_8566286296963951295/restorePoints/AzureBackup_20250228_053642/disks/VD-PRD-ATL01DGST01-02-DATA?id=ab88a997-d627-4eca-b966-a56a5824e5c3"
  }


  atlassianprodgluster01-datadisk-001-20250228-221117 = {
    vm_name              = "atlassian-prod-gluster-01"
    disk_size_gb         = 1024
    create_option        = "Restore"
    storage_account_type = "StandardSSD_LRS"
    lun                  = 1
    caching              = "None"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01dgst01.cp.cjs.hmcts.net_8566286296963951295/restorePoints/AzureBackup_20250228_053642/disks/VD-PRD-ATLJCC-01-WAL?id=aecf4973-54c9-4d97-9b5c-16da5f124726"
  }


  atlassianprodgluster02-datadisk-000-20250228-221141 = {
    vm_name              = "atlassian-prod-gluster-02"
    disk_size_gb         = 4000
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01dgst02.cp.cjs.hmcts.net_8566286296193198296/restorePoints/AzureBackup_20250228_053704/disks/VD-PRD-ATL01DGST02-02-DATA?id=d4e1d261-303d-493c-9342-baba9d4083a0"
  }


  atlassianprodgluster03-datadisk-000-20250228-221204 = {
    vm_name              = "atlassian-prod-gluster-03"
    disk_size_gb         = 4000
    create_option        = "Restore"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
    source_resource_id   = "/subscriptions/79898897-729c-41a0-a5ca-53c764839d95/resourceGroups/AzureBackupRG_uksouth_1/providers/Microsoft.Compute/restorePointCollections/AzureBackup_prdatl01dgst03.cp.cjs.hmcts.net_8566286297280434440/restorePoints/AzureBackup_20250228_053718/disks/VD-PRD-ATL01DGST03-02-DATA?id=5d0e82fa-26db-4a48-813a-f244ac4cf93d"
  }
}

nics = {
  atlassian-prod-jira-01-nic-0fad0fe6e8d94210be9488435aa28b09 = {
    ip_configuration = {
      primary = {
        name                  = "705e02155ab44798b99713fe52224b8e"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.196"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-jira-02-nic-b0cfdcf4e4de498ea2a5bc53c79cfeed = {
    ip_configuration = {
      primary = {
        name                  = "a8aef35e1a1c47e8b91afcb8a99efed2"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.197"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-jira-03-nic-4b4dcb7535b74ab79a40c21ae805c7d0 = {
    ip_configuration = {
      primary = {
        name                  = "1a576ffad2c14fb5a687585c4609cbd1"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.198"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-crowd-01-nic-b4d13bce7fa44641a6a44c8f191ddc25 = {
    ip_configuration = {
      primary = {
        name                  = "576b6dbf5ebb40f2946f7cded01a4175"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.199"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }

  }

  atlassian-prod-confluence-02-nic-c76f35248e73463ba673913dbd6e2a56 = {
    ip_configuration = {
      primary = {
        name                  = "4fef97ab3bdc4ae89b78b8337f00025a"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.200"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-confluence-04-nic-fe70ffff677e4b70b231293c054a5914 = {
    ip_configuration = {
      primary = {
        name                  = "910ffe84a80d4a0eae29aacc0a3d4db7"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.201"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-prod-gluster-01-nic-1c8cb6fa1a7a488db7cb7a70c181164f = {
    ip_configuration = {
      primary = {
        name                  = "110ff079767845b292b33fd6d57aa25f"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.132"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-dat"
      }
    }
  }

  atlassian-prod-gluster-02-nic-cd44e7ead6654137a23f3daefc5f00f6 = {
    ip_configuration = {
      primary = {
        name                  = "e55df150a16144c4a648c9ba1b0a6958"
        private_ip_allocation = "Static"
        private_ip_address    = "10.1.4.133"
        subnet_name           = "atlassian-int-prod-vnet-atlassian-int-subnet-dat"
      }
    }
  }

  atlassian-prod-gluster-03-nic-33273cfe1f254cc5819f2639fc68cc3d = {
    ip_configuration = {
      primary = {
        name                  = "1844d64e71f74fcfbe3314949966908d"
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
      ignore_case = false
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

flex_server_backup_retention_days = 35


