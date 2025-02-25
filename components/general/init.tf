terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.9.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azurerm" {
  alias = "dns"
  features {}
  subscription_id = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
}

provider "azurerm" {
  alias = "stg"
  features {}
  subscription_id = "74dacd4f-a248-45bb-a2f0-af700dc4cf68" #DTS-SHAREDSERVICES-STG
}

provider "azurerm" {
  alias = "soc"
  features {}
  subscription_id = "8ae5b3b6-0b12-4888-b894-4cec33c92292"
}

provider "azurerm" {
  alias = "cnp"
  features {}
  subscription_id = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
}

provider "azurerm" {
  alias                      = "dcr"
  skip_provider_registration = "true"
  features {}
  subscription_id = var.env == "prod" ? "8999dec3-0104-4a27-94ee-6588559729d1" : "1c4f0704-a29e-403d-b719-b90c34ef14c9"
}
