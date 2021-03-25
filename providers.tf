terraform {
  required_version = "~> 0.13.5"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 2.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.34"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 0.11"
    }
  }
}
