
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
      "allow_atlassian-int-subnet-app" = {
        name_override              = "allow_atlassian-int-subnet-app"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Any"
        source_port_range          = "*"
        destination_port_range     = "80,443,22,5801,5701,5432,54327,8080,8090,8091,8095,24007,24008,25500,49152,49153,49154,49155,49156,49157,49158,49159,49160,5701,1099,8005,8080,40001,40011"
        source_address_prefix      = "10.0.4.192/26"
        destination_address_prefix = "*"
      }
    }
  }
}
