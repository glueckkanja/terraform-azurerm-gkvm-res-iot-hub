terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
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
  storage_use_azuread = true
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

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.6.0"

  location                 = azurerm_resource_group.this.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.this.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
  containers = {
    iothub = {
      name = "iothub"
      metadata = {
        description = "This is the iothub container"
      }
      role_assignments = {
        iothub = {
          principal_id               = module.user_assigned_identity.principal_id
          role_definition_id_or_name = "Storage Blob Data Contributor"
        }
      }
    }
  }
  network_rules                 = null
  public_network_access_enabled = true
  shared_access_key_enabled     = true
  tags                          = local.tags

  depends_on = [module.user_assigned_identity]
}

module "eventhub" {
  source  = "Azure/avm-res-eventhub-namespace/azurerm"
  version = "~> 0.1.0"

  location            = azurerm_resource_group.this.location
  name                = module.naming.eventhub.name_unique
  resource_group_name = azurerm_resource_group.this.name
  event_hubs = {
    iothub = {
      resource_group_name = azurerm_resource_group.this.name
      namespace_name      = module.naming.eventhub.name_unique
      partition_count     = 4
      message_retention   = 1
      status              = "Active"
      role_assignments = {
        iothub = {
          principal_id               = module.user_assigned_identity.principal_id
          role_definition_id_or_name = "Azure Event Hubs Data Sender"
        }
      }
    }
  }
  public_network_access_enabled = true
  tags                          = local.tags
}

module "user_assigned_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "~> 0.3.0"

  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
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
  managed_identities = {
    user_assigned_resource_ids = [module.user_assigned_identity.resource_id]
  }
  routing = {
    endpoints = {
      event_hubs = [
        {
          name                     = "eventHub"
          event_hub_namespace_name = module.eventhub.resource.name
          authentication_type      = "identityBased"
          entity_path              = module.eventhub.resource_eventhubs.iothub.name
          identity = {
            user_assigned_identity = module.user_assigned_identity.resource_id
          }
        }
      ]
      storage_containers = [
        {
          name                = "iothub"
          container_name      = "iothub"
          authentication_type = "identityBased"
          endpoint_uri        = module.storage_account.resource.primary_blob_endpoint
          identity = {
            user_assigned_identity = module.user_assigned_identity.resource_id
          }
        }
      ]
    }
    routes = [
      {
        name           = "eventHub"
        endpoint_names = ["eventHub"]
        source         = "DeviceMessages"
        condition      = "true"
        is_enabled     = true
      },
      {
        name           = "storage"
        endpoint_names = ["iothub"]
        source         = "DeviceMessages"
        condition      = "true"
        is_enabled     = true
      }
    ]
  }
  tags = local.tags

  depends_on = [module.storage_account, module.eventhub, module.user_assigned_identity]
}
