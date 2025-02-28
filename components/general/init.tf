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
  subscription_id = var.ss-env-sub #DTS-SHAREDSERVICES-STG | DTS-SHAREDSERVICES-PROD
}

provider "azurerm" {
  alias = "cft-mgmt"
  features {}
  subscription_id = "ed302caf-ec27-4c64-a05e-85731c3ce90e" #Reform-CFT-Mgmt
}
