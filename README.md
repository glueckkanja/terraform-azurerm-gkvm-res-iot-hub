<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

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

- [azapi_resource.this](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azapi_resource.rg](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource) (data source)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id)

Description: The resource group ID where the resource will be created.

Type: `string`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: SKU settings for the IoT Hub.
- `capacity` (number): The capacity of the SKU.
- `name` (string): The name of the SKU (e.g., 'S1', 'B1').

Type:

```hcl
object({
    capacity = number
    name     = string
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_allowed_fqdn_list"></a> [allowed\_fqdn\_list](#input\_allowed\_fqdn\_list)

Description: List of allowed FQDNs for the IoT Hub.

Type: `list(string)`

Default: `[]`

### <a name="input_cloud_to_device"></a> [cloud\_to\_device](#input\_cloud\_to\_device)

Description: Cloud-to-device messaging settings.
- `default_ttl_as_iso8601` (string): Default time-to-live for cloud-to-device messages (ISO8601 format).
- `feedback` (object):
    - `lock_duration_as_iso8601` (string): Lock duration for feedback messages (ISO8601 format).
    - `max_delivery_count` (number): Maximum delivery count for feedback messages.
    - `ttl_as_iso8601` (string): Time-to-live for feedback messages (ISO8601 format).
- `max_delivery_count` (number): Maximum delivery count for cloud-to-device messages.

Type:

```hcl
object({
    default_ttl_as_iso8601 = string
    feedback = object({
      lock_duration_as_iso8601 = string
      max_delivery_count       = number
      ttl_as_iso8601           = string
    })
    max_delivery_count = number
  })
```

Default:

```json
{
  "default_ttl_as_iso8601": "PT1H",
  "feedback": {
    "lock_duration_as_iso8601": "PT1M",
    "max_delivery_count": 10,
    "ttl_as_iso8601": "PT1H"
  },
  "max_delivery_count": 10
}
```

### <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key)

Description: A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.

Type:

```hcl
object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
```

Default: `null`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_disable_local_auth"></a> [disable\_local\_auth](#input\_disable\_local\_auth)

Description: Whether local authentication methods are disabled.

Type: `bool`

Default: `null`

### <a name="input_enable_data_residency"></a> [enable\_data\_residency](#input\_enable\_data\_residency)

Description: Whether data residency is enabled.

Type: `bool`

Default: `null`

### <a name="input_enable_file_upload_notifications"></a> [enable\_file\_upload\_notifications](#input\_enable\_file\_upload\_notifications)

Description: Whether file upload notifications are enabled.

Type: `bool`

Default: `false`

### <a name="input_enable_root_certificate_v2"></a> [enable\_root\_certificate\_v2](#input\_enable\_root\_certificate\_v2)

Description: Whether to enable Root Certificate V2.

Type: `bool`

Default: `true`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_event_hub_endpoints"></a> [event\_hub\_endpoints](#input\_event\_hub\_endpoints)

Description: Event Hub endpoints configuration.
- `events` (object, required):
    - `partition_count` (number, required): Number of partitions for the Event Hub.
    - `retention_time_in_days` (number, required): Retention time in days for the Event Hub.

Type:

```hcl
object({
    events = object({
      partition_count        = number # Required
      retention_time_in_days = number # Required
    })
  })
```

Default:

```json
{
  "events": {
    "partition_count": 4,
    "retention_time_in_days": 1
  }
}
```

### <a name="input_ip_filter_rules"></a> [ip\_filter\_rules](#input\_ip\_filter\_rules)

Description: List of IP filter rules for the IoT Hub.  
Each object contains:
- `action` (string, required): The action for the rule (e.g., "Accept" or "Reject").
- `filter_name` (string, required): The name of the filter rule.
- `ip_mask` (string, required): The IP mask to filter.

Type:

```hcl
list(object({
    action      = string # Required
    filter_name = string # Required
    ip_mask     = string # Required
  }))
```

Default: `[]`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description:   Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_messaging_endpoints"></a> [messaging\_endpoints](#input\_messaging\_endpoints)

Description: Messaging endpoints configuration.
- `file_notifications` (object, required):
    - `lock_duration_as_iso8601` (string, required): Lock duration for file notifications (ISO8601 format).
    - `max_delivery_count` (number, required): Maximum delivery count for file notifications.
    - `ttl_as_iso8601` (string, required): Time-to-live for file notifications (ISO8601 format).

Type:

```hcl
object({
    file_notifications = object({
      lock_duration_as_iso8601 = string # Required
      max_delivery_count       = number # Required
      ttl_as_iso8601           = string # Required
    })
  })
```

Default:

```json
{
  "file_notifications": {
    "lock_duration_as_iso8601": "PT1M",
    "max_delivery_count": 10,
    "ttl_as_iso8601": "PT1H"
  }
}
```

### <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version)

Description: The minimum TLS version to be used for the IoT Hub. Possible values are '1.0', ' '1.2'.

Type: `string`

Default: `"1.2"`

### <a name="input_network_rule_sets"></a> [network\_rule\_sets](#input\_network\_rule\_sets)

Description: Network rule sets for the IoT Hub.
- `apply_to_built_in_event_hub_endpoint` (bool, required): Whether to apply rules to the built-in Event Hub endpoint.
- `default_action` (string, required): Default action for network rules (e.g., "Allow" or "Deny").
- `ip_rules` (list of object, required): List of IP rules, each with:
    - `action` (string, required): The action for the rule.
    - `filter_name` (string, required): The name of the filter rule.
    - `ip_mask` (string, required): The IP mask to filter.

Type:

```hcl
object({
    apply_to_built_in_event_hub_endpoint = bool   # Required
    default_action                       = string # Required
    ip_rules = list(object({
      action      = string # Required
      filter_name = string # Required
      ip_mask     = string # Required
    }))
  })
```

Default: `null`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description:   A map of private endpoints to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the private endpoint. One will be generated if not set.
  - `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
    - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
    - `principal_id` - The ID of the principal to assign the role to.
    - `description` - (Optional) The description of the role assignment.
    - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
    - `condition` - (Optional) The condition which will be used to scope the role assignment.
    - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
    - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
    - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
  - `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
    - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
    - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  - `tags` - (Optional) A mapping of tags to assign to the private endpoint.
  - `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
  - `subresource_name` - The name of the sub resource for the private endpoint.
  - `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
  - `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
  - `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
  - `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
  - `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
  - `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Key Vault.
  - `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
    - `name` - The name of the IP configuration.
    - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags               = optional(map(string), null)
    subnet_resource_id = string
    #subresource_name                        = string # NOTE: `subresource_name` can be excluded if the resource does not support multiple sub resource types (e.g. storage account supports blob, queue, etc)
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
```

Default: `{}`

### <a name="input_private_endpoints_manage_dns_zone_group"></a> [private\_endpoints\_manage\_dns\_zone\_group](#input\_private\_endpoints\_manage\_dns\_zone\_group)

Description: Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy.

Type: `bool`

Default: `true`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Whether public network access is enabled. Possible values: 'Enabled', 'Disabled'.

Type: `string`

Default: `"Enabled"`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_routing"></a> [routing](#input\_routing)

Description: Routing configuration for the IoT Hub.
- `endpoints` (object, optional):
    - `cosmosdb_sql_containers` (list of object, optional): Cosmos DB SQL container endpoints.
    - `event_hubs` (list of object, required): Event Hub endpoints.
    - `service_bus_queues` (list of object, required): Service Bus queue endpoints.
    - `service_bus_topics` (list of object, required): Service Bus topic endpoints.
    - `storage_containers` (list of object, required): Storage container endpoints.
- `fallback_route` (object, optional): Fallback route configuration.
    - `condition` (string, optional): Condition for the fallback route.
    - `endpoint_names` (list of string, required): Endpoint names for the fallback route.
    - `is_enabled` (bool, required): Whether the fallback route is enabled.
    - `name` (string, optional): Name of the fallback route.
    - `source` (string, required): Source of the fallback route.
- `routes` (list of object, optional): Custom routes.
    - `condition` (string, optional): Condition for the route.
    - `endpoint_names` (list of string, optional): Endpoint names for the route.
    - `is_enabled` (bool, optional): Whether the route is enabled.
    - `name` (string, required): Name of the route.
    - `source` (string, required): Source of the route.

Type:

```hcl
object({
    endpoints = optional(object({
      cosmosdb_sql_containers = optional(list(object({
        authentication_type = string # Required
        container_name      = string # Required
        database_name       = string # Required
        endpoint_uri        = string # Required
        identity = optional(object({
          user_assigned_identity = string # Required if provided
        }), null)
        name                   = string           # Required
        partition_key_name     = optional(string) # Optional
        partition_key_template = optional(string) # Optional
        primary_key            = optional(string) # Optional
        resource_group         = optional(string) # Optional
        secondary_key          = optional(string) # Optional
        subscription_id        = optional(string) # Optional
      })), [])
      event_hubs = optional(list(object({
        name                     = string # Required
        authentication_type      = optional(string)
        connection_string        = optional(string)
        endpoint_uri             = optional(string, null)
        event_hub_namespace_name = optional(string, null)
        entity_path              = optional(string)
        identity = optional(object({
          user_assigned_identity = string # Required if provided
        }), null)
        resource_group  = optional(string) # Optional
        subscription_id = optional(string) # Optional
      })), [])
      service_bus_queues = optional(list(object({
        name                = string           # Required
        authentication_type = optional(string) # Optional
        connection_string   = optional(string) # Optional
        endpoint_uri        = optional(string) # Optional
        entity_path         = optional(string) # Optional
        identity = optional(object({
          user_assigned_identity = string # Required if provided
        }), null)
        resource_group  = optional(string) # Optional
        subscription_id = optional(string) # Optional
      })), [])
      service_bus_topics = optional(list(object({
        name                = string           # Required
        authentication_type = optional(string) # Optional
        connection_string   = optional(string) # Optional
        endpoint_uri        = optional(string) # Optional
        entity_path         = optional(string) # Optional
        identity = optional(object({
          user_assigned_identity = string # Required if provided
        }), null)
        resource_group  = optional(string) # Optional
        subscription_id = optional(string) # Optional
      })), [])
      storage_containers = optional(list(object({
        container_name             = string                                                              # Required
        name                       = string                                                              # Required
        connection_string          = optional(string)                                                    # Optional
        authentication_type        = optional(string)                                                    # Optional
        batch_frequency_in_seconds = optional(number, 300)                                               # Optional
        encoding                   = optional(string, "avro")                                            # Optional
        endpoint_uri               = optional(string)                                                    # Optional
        file_name_format           = optional(string, "{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}") # Optional
        identity = optional(object({
          user_assigned_identity = string # Required if provided
        }))
        max_chunk_size_in_bytes = optional(number, 314572800) # Optional
        resource_group          = optional(string)            # Optional
        subscription_id         = optional(string)            # Optional
      })), [])
      }), {
      cosmosdb_sql_containers = []
      event_hubs              = []
      service_bus_queues      = []
      service_bus_topics      = []
      storage_containers      = []
    })
    fallback_route = optional(object({
      condition      = optional(string, "true")
      endpoint_names = optional(list(string), ["events"])
      is_enabled     = optional(bool, false)
      name           = optional(string, "$fallback")
      source         = optional(string, "DeviceMessages")
      })
      , {
        condition = true
        endpoint_names = [
          "events"
        ]
        is_enabled = false
        name       = "$fallback"
        source     = "DeviceMessages"
    })
    routes = optional(list(object({
      condition      = optional(string)       # Optional
      endpoint_names = optional(list(string)) # Optional
      is_enabled     = optional(bool)         # Optional
      name           = string                 # Required
      source         = string                 # Required
    })), [])
  })
```

Default:

```json
{
  "endpoints": {
    "cosmosdb_sql_containers": [],
    "event_hubs": [],
    "service_bus_queues": [],
    "service_bus_topics": [],
    "storage_containers": []
  },
  "fallback_route": {
    "condition": true,
    "endpoint_names": [
      "events"
    ],
    "is_enabled": false,
    "name": "$fallback",
    "source": "DeviceMessages"
  },
  "routes": []
}
```

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description:   A map of the private endpoints created.

### <a name="output_resource"></a> [resource](#output\_resource)

Description:   The IoT Hub resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description:   The ID of the IoT Hub.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->