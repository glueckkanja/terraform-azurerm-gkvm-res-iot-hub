output "private_endpoints" {
  description = <<DESCRIPTION
  A map of the private endpoints created.
  DESCRIPTION
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

output "resource" {
  description = <<DESCRIPTION
  The IoT Hub resource.
  DESCRIPTION
  value       = azapi_resource.this
}

output "resource_id" {
  description = <<DESCRIPTION
  The ID of the IoT Hub.
  DESCRIPTION
  value       = azapi_resource.this.id
}
