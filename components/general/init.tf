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

provider "azurerm" {
  alias = "soc"
  features {}
  subscription_id = "8ae5b3b6-0b12-4888-b894-4cec33c92292"
}

provider "azurerm" {
  alias = "cnp"
  features {}
  subscription_id = var.env == "prod" ? "8999dec3-0104-4a27-94ee-6588559729d1" : "1c4f0704-a29e-403d-b719-b90c34ef14c9"
}

provider "azurerm" {
  alias                      = "dcr"
  skip_provider_registration = "true"
  features {}
  subscription_id = var.env == "prod" ? "8999dec3-0104-4a27-94ee-6588559729d1" : "1c4f0704-a29e-403d-b719-b90c34ef14c9"
}

provider "azurerm" {
  alias = "sds-prod"
  features {}
  subscription_id = "5ca62022-6aa2-4cee-aaa7-e7536c8d566c" #DTS-SHAREDSERVICES-PROD
}