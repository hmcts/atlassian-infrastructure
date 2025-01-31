env             = "nonprod"
subscription_id = "b7d2bd5f-b744-4acc-9c73-e068cec2e8d8"
cnp_vault_sub   = "1c4f0704-a29e-403d-b719-b90c34ef14c9"

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
      atlassian-int-subnet-postgres = {
        name_override     = "atlassian-int-subnet-postgres"
        address_prefixes  = ["10.0.4.0/26"]
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
      "allow_aks_ssh" = {
        name_override              = "allow_aks_ssh"
        priority                   = 620
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["10.148.16.0/20", "10.148.0.0/20"]
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
        destination_address_prefix = "10.0.4.0/26"
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
      "allow_aks_ssh" = {
        name_override              = "allow_aks_ssh"
        priority                   = 620
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["10.148.16.0/20", "10.148.0.0/20"]
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
        destination_address_prefix = "10.0.4.0/26"
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
      "postgres_private" = {
        name_override              = "postgres_private"
        priority                   = 150
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "10.0.4.0/26"
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
    backend_pool_ip_addresses = ["10.0.4.198", "10.0.4.199", "10.0.4.196"]
    backend_pool_fqdns        = []
  },
  {
    name                      = "appgw-backend-pool-crd"
    backend_pool_ip_addresses = ["10.0.4.197"]
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
    key_vault_secret_id = "https://acmedtssdsprod.vault.azure.net/secrets/staging-tools-hmcts-net/c3c238f558e1464c80d41aeebbba4cea"
  }
]

enable_http2         = true
storage_account_name = "atlassiannonprod"
autoShutdown         = true

vms = {
  atlassian-nonprod-jira-01 = {
    computer_name      = "prdatl01ajra01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-nonprod-jira-01-nic-ae42a8594ebb446cb08f04a919d15177"
    os_disk_name       = "atlassiannonprodjira01-osdisk-20250115-102743"
    private_ip_address = "10.0.4.198"
    app                = "jira"
  }

  atlassian-nonprod-jira-02 = {
    computer_name      = "prdatl01ajra02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-nonprod-jira-02-nic-69fb98d7b08e4fd7a5cfd2d52d7a551e"
    os_disk_name       = "atlassiannonprodjira02-osdisk-20250115-102817"
    private_ip_address = "10.0.4.199"
    app                = "jira"
  }

  atlassian-nonprod-jira-03 = {
    computer_name      = "prdatl01ajra03.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-nonprod-jira-03-nic-dc5e66a89abe413a9b6552cb7917a1fb"
    os_disk_name       = "atlassiannonprodjira03-osdisk-20250115-102620"
    private_ip_address = "10.0.4.196"
    app                = "jira"
  }

  atlassian-nonprod-crowd-01 = {
    computer_name      = "prdatl01acrd01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E4s_v3"
    nic_name           = "atlassian-nonprod-crowd-01-nic-6fab8d5cad484bbd8527a72a388d91d2"
    os_disk_name       = "atlassiannonprodcrowd01-osdisk-20250115-103215"
    private_ip_address = "10.0.4.197"
    app                = "crowd"
  }

  atlassian-nonprod-confluence-02 = {
    computer_name      = "prdatl01acnf02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-nonprod-confluence-02-nic-b84332a810274e879a33a6f38a7df04a"
    os_disk_name       = "atlassiannonprodconfluence02-osdisk-20250115-103537"
    private_ip_address = "10.0.4.201"
    app                = "confluence"
  }

  atlassian-nonprod-confluence-04 = {
    computer_name      = "prdatl01acnf04.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-nonprod-confluence-04-nic-4613cc6b09804b27aca60fa089ef0cb3"
    os_disk_name       = "atlassiannonprodconfluence04-osdisk-20250115-103905"
    private_ip_address = "10.0.4.200"
    app                = "confluence"
  }
  atlassian-nonprod-gluster-01 = {
    computer_name      = "PRDATL01DGST01.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-nonprod-gluster-01-nic-9d7a4faa7a584b8a93625c8a890aaaa2"
    os_disk_name       = "atlassiannonprodgluster01-osdisk-20250115-110018"
    private_ip_address = "10.0.4.132"
    app                = "gluster"
  }

  atlassian-nonprod-gluster-02 = {
    computer_name      = "prdatl01dgst02.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-nonprod-gluster-02-nic-5d520339a4a3439ea10b42309dd60d89"
    os_disk_name       = "atlassiannonprodgluster02-osdisk-20250115-110126"
    private_ip_address = "10.0.4.133"
    app                = "gluster"
  }

  atlassian-nonprod-gluster-03 = {
    computer_name      = "prdatl01dgst03.cp.cjs.hmcts.net"
    vm_size            = "Standard_E8s_v3"
    nic_name           = "atlassian-nonprod-gluster-03-nic-789c1d7bf88c4ff2a65e0bffd22dd45c"
    os_disk_name       = "atlassiannonprodgluster03-osdisk-20250115-110154"
    private_ip_address = "10.0.4.134"
    app                = "gluster"
  }
}

data_disks = {
  atlassiannonprodjira01-datadisk-000-20250115-102743 = {
    vm_name              = "atlassian-nonprod-jira-01"
    disk_size_gb         = 100
    create_option        = "Import"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
  }

  atlassiannonprodconfluence02-datadisk-000-20250115-103537 = {
    vm_name              = "atlassian-nonprod-confluence-02"
    disk_size_gb         = 128
    create_option        = "Import"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
  }

  atlassiannonprodconfluence04-datadisk-000-20250115-103905 = {
    vm_name              = "atlassian-nonprod-confluence-04"
    disk_size_gb         = 128
    create_option        = "Import"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadOnly"
  }

  atlassiannonprodgluster01-datadisk-000-20250115-110018 = {
    vm_name              = "atlassian-nonprod-gluster-01"
    disk_size_gb         = 4000
    create_option        = "Import"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
  }


  atlassiannonprodgluster01-datadisk-001-20250115-110018 = {
    vm_name              = "atlassian-nonprod-gluster-01"
    disk_size_gb         = 1024
    create_option        = "Import"
    storage_account_type = "StandardSSD_LRS"
    lun                  = 1
    caching              = "None"
  }


  atlassiannonprodgluster02-datadisk-000-20250115-110126 = {
    vm_name              = "atlassian-nonprod-gluster-02"
    disk_size_gb         = 4000
    create_option        = "Import"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
  }


  atlassiannonprodgluster03-datadisk-000-20250115-110154 = {
    vm_name              = "atlassian-nonprod-gluster-03"
    disk_size_gb         = 4000
    create_option        = "Import"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    caching              = "ReadWrite"
  }
}

nics = {
  atlassian-nonprod-jira-01-nic-ae42a8594ebb446cb08f04a919d15177 = {
    ip_configuration = {
      primary = {
        name                  = "a046c86bfaf340a0ac67759518ed0593"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.198"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-nonprod-jira-02-nic-69fb98d7b08e4fd7a5cfd2d52d7a551e = {
    ip_configuration = {
      primary = {
        name                  = "956345df6048440383d8d7e13ece98e2"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.199"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-nonprod-jira-03-nic-dc5e66a89abe413a9b6552cb7917a1fb = {
    ip_configuration = {
      primary = {
        name                  = "67d33c61f79440fcb3344fc02673bdae"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.196"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-nonprod-crowd-01-nic-6fab8d5cad484bbd8527a72a388d91d2 = {
    ip_configuration = {
      primary = {
        name                  = "2833ba74d709498988492fa0ee9c3e95"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.197"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-app"
      }
    }

  }

  atlassian-nonprod-confluence-02-nic-b84332a810274e879a33a6f38a7df04a = {
    ip_configuration = {
      primary = {
        name                  = "ddadbc2efc734bc7bcc236336026b501"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.201"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-nonprod-confluence-04-nic-4613cc6b09804b27aca60fa089ef0cb3 = {
    ip_configuration = {
      primary = {
        name                  = "720ee19ebf504fe69bf991d77c94bfbc"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.200"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-app"
      }
    }
  }

  atlassian-nonprod-gluster-01-nic-9d7a4faa7a584b8a93625c8a890aaaa2 = {
    ip_configuration = {
      primary = {
        name                  = "b9eac8ecb6a44fd9b0c6a4c244fa77ec"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.132"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-dat"
      }
    }
  }

  atlassian-nonprod-gluster-02-nic-5d520339a4a3439ea10b42309dd60d89 = {
    ip_configuration = {
      primary = {
        name                  = "dbd462d9274e49bda9025e3fc2034dc8"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.133"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-dat"
      }
    }
  }

  atlassian-nonprod-gluster-03-nic-789c1d7bf88c4ff2a65e0bffd22dd45c = {
    ip_configuration = {
      primary = {
        name                  = "213e090d693745268e3483f55897a2e4"
        private_ip_allocation = "Static"
        private_ip_address    = "10.0.4.134"
        subnet_name           = "atlassian-int-nonprod-vnet-atlassian-int-subnet-dat"
      }
    }
  }
}



frontend_private_ip_address = "10.0.4.150"

lb_backend_addresses = {
  lb_address_1 = {
    name = "atlassian-nonprod-gluster-01"
    ip   = "10.0.4.132"
  }
  lb_address_2 = {
    name = "atlassian-nonprod-gluster-02"
    ip   = "10.0.4.133"
  }
  lb_address_3 = {
    name = "atlassian-nonprod-gluster-03"
    ip   = "10.0.4.134"
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

enable_rewrite_rule_set = true # Enables the rewrite rule set on Application Gateway when set to "true"
