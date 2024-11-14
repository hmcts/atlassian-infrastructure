
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
        name_override    = "atlassian-int-subnet-dat"
        address_prefixes = ["10.0.4.128/26"]
      }
      atlassian-int-subnet-app = {
        name_override    = "atlassian-int-subnet-app"
        address_prefixes = ["10.0.4.192/26"]
      }
    }
  }
  atlassian-dmz-nonprod-vnet = {
    name_override = "atlassian-dmz-nonprod-vnet"
    address_space = ["10.0.8.0/22"]
    subnets = {
      atlassian-dmz-subnet = {
        name_override    = "atlassian-dmz-subnet"
        address_prefixes = ["10.0.8.0/28"]
      }
      atlassian-dmz-subnet-appgw = {
        name_override    = "atlassian-dmz-subnet-appgw"
        address_prefixes = ["10.0.8.16/28"]
      }
    }
  }
}


network_security_groups = {
  nsg = {
    subnets = ["atlassian-int-nonprod-vnet-atlassian-int-subnet-app"]
    rules = {
      "allow_http" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "10.10.10.0/24"
      }
    }
  }
}
