data "azapi_resource" "rg" {
  type        = "Microsoft.Resources/resourceGroups@2024-11-01"
  resource_id = var.resource_group_id
}
