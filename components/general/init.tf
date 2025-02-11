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
  alias = "prod"
  features {}
  subscription_id = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c" #DTS-SHAREDSERVICES-PROD
}
