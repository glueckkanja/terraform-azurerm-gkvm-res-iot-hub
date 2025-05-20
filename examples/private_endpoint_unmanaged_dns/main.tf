terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    # TODO: Ensure all required providers are listed here and the version property includes a constraint on the maximum major version.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "modtm" {
  enabled = true
}

provider "azapi" {}

locals {
  tags = {
    environment = "dev"
    cost_center = "12345"
    owner       = "dev-team"
    project     = "iot-hub"
  }
}
## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.7"

  address_space       = ["192.168.0.0/24"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  name                = module.naming.virtual_network.name_unique
  subnets = {
    private_endpoints = {
      name                              = "private_endpoints"
      address_prefixes                  = ["192.168.0.0/24"]
      private_endpoint_network_policies = "Disabled"
      service_endpoints                 = null
    }
  }
  tags = local.tags
}

# This is the module call
module "iot_hub" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.iothub.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku = {
    name     = "S1"
    capacity = 1
  }
  enable_telemetry = var.enable_telemetry # see variables.tf
  network_rule_sets = {
    default_action                       = "Deny"
    apply_to_built_in_event_hub_endpoint = false
    ip_rules = [
      {
        action      = "Allow"
        ip_mask     = "XXX.XXX.XXX.XXX/32" # Replace with your IP address
        filter_name = "test"
      }
    ]
  }
  private_endpoints = {
    iothub = {
      subnet_resource_id = module.virtual_network.subnets.private_endpoints.resource_id
    }
  }
  private_endpoints_manage_dns_zone_group = false
  tags                                    = local.tags
}
