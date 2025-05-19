variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{3,50}$", var.name))
    error_message = "The name must be between 3 and 50 characters long and can only contain alphanumerics and hypens."
  }
}

# This is required for most resource modules
variable "resource_group_id" {
  type        = string
  description = "The resource group ID where the resource will be created."
  nullable    = false
}

variable "sku" {
  type = object({
    capacity = number
    name     = string
  })
  description = <<DESCRIPTION
SKU settings for the IoT Hub.
- `capacity` (number): The capacity of the SKU.
- `name` (string): The name of the SKU (e.g., 'S1', 'B1').
DESCRIPTION
}

variable "allowed_fqdn_list" {
  type        = list(string)
  default     = []
  description = "List of allowed FQDNs for the IoT Hub."
}

variable "cloud_to_device" {
  type = object({
    default_ttl_as_iso8601 = string
    feedback = object({
      lock_duration_as_iso8601 = string
      max_delivery_count       = number
      ttl_as_iso8601           = string
    })
    max_delivery_count = number
  })
  default = {
    default_ttl_as_iso8601 = "PT1H"
    feedback = {
      lock_duration_as_iso8601 = "PT1M"
      max_delivery_count       = 10
      ttl_as_iso8601           = "PT1H"
    }
    max_delivery_count = 10
  }
  description = <<DESCRIPTION
Cloud-to-device messaging settings.
- `default_ttl_as_iso8601` (string): Default time-to-live for cloud-to-device messages (ISO8601 format).
- `feedback` (object):
    - `lock_duration_as_iso8601` (string): Lock duration for feedback messages (ISO8601 format).
    - `max_delivery_count` (number): Maximum delivery count for feedback messages.
    - `ttl_as_iso8601` (string): Time-to-live for feedback messages (ISO8601 format).
- `max_delivery_count` (number): Maximum delivery count for cloud-to-device messages.
DESCRIPTION
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
DESCRIPTION
}

variable "diagnostic_settings" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "disable_local_auth" {
  type        = bool
  default     = null
  description = "Whether local authentication methods are disabled."
}

variable "enable_data_residency" {
  type        = bool
  default     = null
  description = "Whether data residency is enabled."
}

variable "enable_file_upload_notifications" {
  type        = bool
  default     = false
  description = "Whether file upload notifications are enabled."
}

variable "enable_root_certificate_v2" {
  type        = bool
  default     = true
  description = "Whether to enable Root Certificate V2."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "event_hub_endpoints" {
  type = object({
    events = object({
      partition_count        = number # Required
      retention_time_in_days = number # Required
    })
  })
  default = {
    events = {
      partition_count        = 4
      retention_time_in_days = 1
    }
  }
  description = <<DESCRIPTION
Event Hub endpoints configuration.
- `events` (object, required):
    - `partition_count` (number, required): Number of partitions for the Event Hub.
    - `retention_time_in_days` (number, required): Retention time in days for the Event Hub.
DESCRIPTION
}

variable "ip_filter_rules" {
  type = list(object({
    action      = string # Required
    filter_name = string # Required
    ip_mask     = string # Required
  }))
  default     = []
  description = <<DESCRIPTION
List of IP filter rules for the IoT Hub.
Each object contains:
- `action` (string, required): The action for the rule (e.g., "Accept" or "Reject").
- `filter_name` (string, required): The name of the filter rule.
- `ip_mask` (string, required): The IP mask to filter.
DESCRIPTION
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
  Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
  DESCRIPTION
  nullable    = false
}

variable "messaging_endpoints" {
  type = object({
    file_notifications = object({
      lock_duration_as_iso8601 = string # Required
      max_delivery_count       = number # Required
      ttl_as_iso8601           = string # Required
    })
  })
  default = {
    file_notifications = {
      lock_duration_as_iso8601 = "PT1M"
      max_delivery_count       = 10
      ttl_as_iso8601           = "PT1H"
    }
  }
  description = <<DESCRIPTION
Messaging endpoints configuration.
- `file_notifications` (object, required):
    - `lock_duration_as_iso8601` (string, required): Lock duration for file notifications (ISO8601 format).
    - `max_delivery_count` (number, required): Maximum delivery count for file notifications.
    - `ttl_as_iso8601` (string, required): Time-to-live for file notifications (ISO8601 format).
DESCRIPTION
}

variable "min_tls_version" {
  type        = string
  default     = "1.2"
  description = <<DESCRIPTION
The minimum TLS version to be used for the IoT Hub. Possible values are '1.0', ' '1.2'.
DESCRIPTION
}

variable "network_rule_sets" {
  type = object({
    apply_to_built_in_event_hub_endpoint = bool   # Required
    default_action                       = string # Required
    ip_rules = list(object({
      action      = string # Required
      filter_name = string # Required
      ip_mask     = string # Required
    }))
  })
  default     = null
  description = <<DESCRIPTION
Network rule sets for the IoT Hub.
- `apply_to_built_in_event_hub_endpoint` (bool, required): Whether to apply rules to the built-in Event Hub endpoint.
- `default_action` (string, required): Default action for network rules (e.g., "Allow" or "Deny").
- `ip_rules` (list of object, required): List of IP rules, each with:
    - `action` (string, required): The action for the rule.
    - `filter_name` (string, required): The name of the filter rule.
    - `ip_mask` (string, required): The IP mask to filter.
DESCRIPTION
}

variable "private_endpoints" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  A map of private endpoints to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
  DESCRIPTION
  nullable    = false
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

variable "public_network_access_enabled" {
  type        = string
  default     = "Enabled"
  description = "Whether public network access is enabled. Possible values: 'Enabled', 'Disabled'."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "routing" {
  type = object({
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
  default = {
    endpoints = {
      cosmosdb_sql_containers = []
      event_hubs              = []
      service_bus_queues      = []
      service_bus_topics      = []
      storage_containers      = []
    }
    fallback_route = {
      condition      = true
      endpoint_names = ["events"]
      is_enabled     = false
      name           = "$fallback"
      source         = "DeviceMessages"
    }
    routes = []
  }
  description = <<DESCRIPTION
Routing configuration for the IoT Hub.

- `endpoints` (object, optional): Custom endpoints for routing.
    - `cosmosdb_sql_containers` (list of object, optional): Cosmos DB SQL container endpoints.
        - `authentication_type` (string, required): Authentication type for the Cosmos DB endpoint.
        - `container_name` (string, required): Name of the Cosmos DB container.
        - `database_name` (string, required): Name of the Cosmos DB database.
        - `endpoint_uri` (string, required): URI of the Cosmos DB endpoint.
        - `identity` (object, optional): User assigned identity for authentication.
        - `name` (string, required): Name of the endpoint.
        - `partition_key_name` (string, optional): Partition key name.
        - `partition_key_template` (string, optional): Partition key template.
        - `primary_key` (string, optional): Primary key for authentication.
        - `resource_group` (string, optional): Resource group of the Cosmos DB.
        - `secondary_key` (string, optional): Secondary key for authentication.
        - `subscription_id` (string, optional): Subscription ID.
    - `event_hubs` (list of object, optional): Event Hub endpoints.
        - `name` (string, required): Name of the Event Hub endpoint.
        - `authentication_type` (string, optional): Authentication type.
        - `connection_string` (string, optional): Connection string.
        - `endpoint_uri` (string, optional): URI of the Event Hub endpoint.
        - `event_hub_namespace_name` (string, optional): Namespace name.
        - `entity_path` (string, optional): Entity path.
        - `identity` (object, optional): User assigned identity for authentication.
        - `resource_group` (string, optional): Resource group of the Event Hub.
        - `subscription_id` (string, optional): Subscription ID.
    - `service_bus_queues` (list of object, optional): Service Bus queue endpoints.
        - `name` (string, required): Name of the Service Bus queue.
        - `authentication_type` (string, optional): Authentication type.
        - `connection_string` (string, optional): Connection string.
        - `endpoint_uri` (string, optional): URI of the Service Bus queue.
        - `entity_path` (string, optional): Entity path.
        - `identity` (object, optional): User assigned identity for authentication.
        - `resource_group` (string, optional): Resource group of the Service Bus.
        - `subscription_id` (string, optional): Subscription ID.
    - `service_bus_topics` (list of object, optional): Service Bus topic endpoints.
        - `name` (string, required): Name of the Service Bus topic.
        - `authentication_type` (string, optional): Authentication type.
        - `connection_string` (string, optional): Connection string.
        - `endpoint_uri` (string, optional): URI of the Service Bus topic.
        - `entity_path` (string, optional): Entity path.
        - `identity` (object, optional): User assigned identity for authentication.
        - `resource_group` (string, optional): Resource group of the Service Bus.
        - `subscription_id` (string, optional): Subscription ID.
    - `storage_containers` (list of object, optional): Storage container endpoints.
        - `container_name` (string, required): Name of the storage container.
        - `name` (string, required): Name of the endpoint.
        - `connection_string` (string, optional): Connection string.
        - `authentication_type` (string, optional): Authentication type.
        - `batch_frequency_in_seconds` (number, optional): Batch frequency in seconds.
        - `encoding` (string, optional): Encoding type.
        - `endpoint_uri` (string, optional): URI of the storage endpoint.
        - `file_name_format` (string, optional): File name format.
        - `identity` (object, optional): User assigned identity for authentication.
        - `max_chunk_size_in_bytes` (number, optional): Maximum chunk size in bytes.
        - `resource_group` (string, optional): Resource group of the storage account.
        - `subscription_id` (string, optional): Subscription ID.

- `fallback_route` (object, optional): Fallback route configuration.
    - `condition` (string, optional): Condition for the fallback route.
    - `endpoint_names` (list of string, optional): Endpoint names for the fallback route.
    - `is_enabled` (bool, optional): Whether the fallback route is enabled.
    - `name` (string, optional): Name of the fallback route.
    - `source` (string, optional): Source of the fallback route.

- `routes` (list of object, optional): Custom routes.
    - `condition` (string, optional): Condition for the route.
    - `endpoint_names` (list of string, optional): Endpoint names for the route.
    - `is_enabled` (bool, optional): Whether the route is enabled.
    - `name` (string, required): Name of the route.
    - `source` (string, required): Source of the route.
DESCRIPTION
}

variable "storage_endpoints" {
  type = object({
    authentication_type = optional(string)
    sas_ttl_as_iso8601  = optional(string)
    connection_string   = string
    container_name      = string
    identity = optional(object({
      user_assigned_identity = string # Required if provided
    }), null)
  })
  default = {
    sas_ttl_as_iso8601  = "PT1H"
    connection_string   = ""
    container_name      = ""
    authentication_type = "keyBased"
    identity            = null
  }
  description = <<DESCRIPTION
Storage endpoints configuration.

- `authentication_type` (string, optional): The authentication type for the storage endpoint. Defaults to `keyBased`.
- `sas_ttl_as_iso8601` (string, optional): SAS token time-to-live in ISO8601 format. Defaults to `PT1H`.
- `connection_string` (string, required): Connection string for the storage account.
- `container_name` (string, required): Name of the storage container.
- `identity` (object, optional): User assigned identity for authentication, if applicable.
DESCRIPTION
}
