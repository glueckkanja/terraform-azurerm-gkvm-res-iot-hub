
resource "azapi_resource" "this" {
  type = "Microsoft.Devices/IotHubs@2023-06-30-preview"
  body = {
    properties = {
      allowedFqdnList = var.allowed_fqdn_list
      cloudToDevice = var.cloud_to_device != null ? {
        defaultTtlAsIso8601 = var.cloud_to_device.default_ttl_as_iso8601
        feedback = var.cloud_to_device != null ? {
          lockDurationAsIso8601 = var.cloud_to_device.feedback.lock_duration_as_iso8601
          maxDeliveryCount      = var.cloud_to_device.feedback.max_delivery_count
          ttlAsIso8601          = var.cloud_to_device.feedback.ttl_as_iso8601
        } : null
        maxDeliveryCount = var.cloud_to_device.max_delivery_count
      } : null
      disableLocalAuth              = var.disable_local_auth
      enableDataResidency           = var.enable_data_residency
      enableFileUploadNotifications = var.enable_file_upload_notifications
      eventHubEndpoints = var.event_hub_endpoints != null ? {
        events = var.event_hub_endpoints.events != null ? {
          partitionCount      = var.event_hub_endpoints.events.partition_count
          retentionTimeInDays = var.event_hub_endpoints.events.retention_time_in_days
        } : null
      } : null
      features = "RootCertificateV2"
      ipFilterRules = var.ip_filter_rules != null ? [
        for rule in var.ip_filter_rules : {
          action     = rule.action
          filterName = rule.filter_name
          ipMask     = rule.ip_mask
        }
      ] : []
      messagingEndpoints = var.messaging_endpoints != null ? {
        fileNotifications = var.messaging_endpoints.file_notifications != null ? {
          lockDurationAsIso8601 = var.messaging_endpoints.file_notifications.lock_duration_as_iso8601
          maxDeliveryCount      = var.messaging_endpoints.file_notifications.max_delivery_count
          ttlAsIso8601          = var.messaging_endpoints.file_notifications.ttl_as_iso8601
        } : null
      } : null
      storageEndpoints = var.storage_endpoints != null || var.enable_file_upload_notifications == true ? {
        "$default" = {
          containerName      = var.storage_endpoints.container_name
          sasTtlAsIso8601    = var.storage_endpoints.sas_ttl_as_iso8601
          connectionString   = var.storage_endpoints.connection_string
          authenticationType = var.storage_endpoints.authentication_type
          identity = var.storage_endpoints.identity != null ? {
            userAssignedIdentity = var.storage_endpoints.user_assigned_identity
          } : null
        }
      } : null
      minTlsVersion = var.min_tls_version != null ? var.min_tls_version : null
      networkRuleSets = var.network_rule_sets != null ? {
        applyToBuiltInEventHubEndpoint = var.network_rule_sets.apply_to_built_in_event_hub_endpoint
        defaultAction                  = var.network_rule_sets.default_action
        ipRules = var.network_rule_sets.ip_rules != null ? [
          for ip_rule in var.network_rule_sets.ip_rules : {
            action     = ip_rule.action
            filterName = ip_rule.filter_name
            ipMask     = ip_rule.ip_mask
          }
        ] : []
      } : null
      publicNetworkAccess = var.public_network_access_enabled
      rootCertificate = var.enable_root_certificate_v2 == true ? {
        enableRootCertificateV2 = var.enable_root_certificate_v2
      } : null
      routing = {
        endpoints = {
          cosmosDBSqlContainers = length(var.routing.endpoints.cosmosdb_sql_containers) > 0 ? [
            for container in var.routing.endpoints.cosmosdb_sql_containers : {
              authenticationType = container.authentication_type
              containerName      = container.container_name
              databaseName       = container.database_name
              endpointUri        = container.endpoint_uri
              identity = container.identity != null ? {
                userAssignedIdentity = container.identity.user_assigned_identity
              } : null
              name                 = container.name
              partitionKeyName     = container.partition_key_name
              partitionKeyTemplate = container.partition_key_template
              primaryKey           = container.primary_key
              resourceGroup        = container.resource_group
              secondaryKey         = container.secondary_key
              subscriptionId       = container.subscription_id
            }
          ] : []
          eventHubs = length(var.routing.endpoints.event_hubs) > 0 ? [
            for event_hub in var.routing.endpoints.event_hubs : {
              name               = event_hub.name
              authenticationType = event_hub.authentication_type
              connectionString   = event_hub.connection_string
              endpointUri        = event_hub.endpoint_uri != null ? event_hub.endpoint_uri : "sb://${event_hub.event_hub_namespace_name}.servicebus.windows.net/"
              entityPath         = event_hub.entity_path
              identity = event_hub.identity != null ? {
                userAssignedIdentity = event_hub.identity.user_assigned_identity
              } : null
              resourceGroup  = event_hub.resource_group
              subscriptionId = event_hub.subscription_id
            }
          ] : []
          serviceBusQueues = length(var.routing.endpoints.service_bus_queues) > 0 ? [
            for queue in var.routing.endpoints.service_bus_queues : {
              name               = queue.name
              authenticationType = queue.authentication_type
              connectionString   = queue.connection_string
              endpointUri        = queue.endpoint_uri
              entityPath         = queue.entity_path
              identity = queue.identity != null ? {
                userAssignedIdentity = queue.identity.user_assigned_identity
              } : null
              resourceGroup  = queue.resource_group
              subscriptionId = queue.subscription_id
            }
          ] : []
          serviceBusTopics = length(var.routing.endpoints.service_bus_topics) > 0 ? [
            for topic in var.routing.endpoints.service_bus_topics : {
              name               = topic.name
              authenticationType = topic.authentication_type
              connectionString   = topic.connection_string
              endpointUri        = topic.endpoint_uri
              entityPath         = topic.entity_path
              identity = topic.identity != null ? {
                userAssignedIdentity = topic.identity.user_assigned_identity
              } : null
              resourceGroup  = topic.resource_group
              subscriptionId = topic.subscription_id
            }
          ] : []
          storageContainers = length(var.routing.endpoints.storage_containers) > 0 ? [
            for container in var.routing.endpoints.storage_containers : {
              containerName           = container.container_name
              name                    = container.name
              authenticationType      = container.authentication_type
              batchFrequencyInSeconds = container.batch_frequency_in_seconds
              connectionString        = container.connection_string
              encoding                = container.encoding
              endpointUri             = container.endpoint_uri
              fileNameFormat          = container.file_name_format
              identity = container.identity != null ? {
                userAssignedIdentity = container.identity.user_assigned_identity
              } : null
              maxChunkSizeInBytes = container.max_chunk_size_in_bytes
              resourceGroup       = container.resource_group
              subscriptionId      = container.subscription_id
            }
          ] : []
        }
        fallbackRoute = {
          condition     = var.routing.fallback_route.condition
          endpointNames = var.routing.fallback_route.endpoint_names
          isEnabled     = var.routing.fallback_route.is_enabled
          name          = var.routing.fallback_route.name
          source        = var.routing.fallback_route.source
        }
        routes = length(var.routing.routes) > 0 ? [
          for route in var.routing.routes : {
            condition     = route.condition
            endpointNames = route.endpoint_names
            isEnabled     = route.is_enabled
            name          = route.name
            source        = route.source
          }
        ] : []
      }
      privateEndpointConnections = []
    }
    etag = null
    sku = {
      capacity = var.sku.capacity
      name     = var.sku.name
    }
  }
  location  = var.location
  name      = var.name
  parent_id = local.resource_group_id
  response_export_values = [
    "body.properties.privateEndpointConnections",

  ]
  tags = var.tags

  ## Resources supporting both SystemAssigned and UserAssigned
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  ## Resources that only support SystemAssigned
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned

    content {
      type = identity.value.type
    }
  }

  lifecycle {
    ignore_changes = [
      body.properties.eventHubEndpoints.events.endpoint,
      body.properties.eventHubEndpoints.events.partitionIds,
      body.properties.eventHubEndpoints.events.path,
      body.properties.rootCertificate.lastUpdatedTime,
      body.properties.privateEndpointConnections,
      body.etag,
    ]
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
