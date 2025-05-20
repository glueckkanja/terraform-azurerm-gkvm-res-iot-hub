<!-- BEGIN_TF_DOCS -->
# Azure IoT Hub with Custom Routing Endpoints Example

This example demonstrates how to deploy an Azure IoT Hub with custom routing endpoints using Terraform. It provisions supporting resources—including a resource group, Event Hub, Storage Account, and User Assigned Managed Identity—and configures IoT Hub message routing to both Event Hub and Storage Account endpoints with identity-based authentication. The configuration uses randomized Azure regions and CAF-compliant naming for uniqueness and best practices.

```hcl
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

  location = azurerm_resource_group.this.location
  name     = module.naming.iothub.name_unique
  sku = {
    name     = "S1"
    capacity = 1
  }
  enable_telemetry = var.enable_telemetry # see variables.tf
  managed_identities = {
    user_assigned_resource_ids = [module.user_assigned_identity.resource_id]
  }
  resource_group_id = azurerm_resource_group.this.id
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_eventhub"></a> [eventhub](#module\_eventhub)

Source: Azure/avm-res-eventhub-namespace/azurerm

Version: ~> 0.1.0

### <a name="module_iot_hub"></a> [iot\_hub](#module\_iot\_hub)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: ~> 0.1

### <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account)

Source: Azure/avm-res-storage-storageaccount/azurerm

Version: ~> 0.6.0

### <a name="module_user_assigned_identity"></a> [user\_assigned\_identity](#module\_user\_assigned\_identity)

Source: Azure/avm-res-managedidentity-userassignedidentity/azurerm

Version: ~> 0.3.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->