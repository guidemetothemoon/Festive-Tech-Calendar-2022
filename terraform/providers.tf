# Provider

terraform {
  required_version = ">=1.0"

  required_providers {
    #Azure Resource Manager
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    #Azure AD
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }

    # Random 3.x
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}