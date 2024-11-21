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
  features {}
  alias           = "live"
  subscription_id = "79898897-729c-41a0-a5ca-53c764839d95"
}
