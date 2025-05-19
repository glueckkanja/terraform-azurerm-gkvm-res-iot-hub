# Azure IoT Hub with Custom Routing Endpoints Example

This example demonstrates how to deploy an Azure IoT Hub with custom routing endpoints using Terraform. It provisions supporting resources—including a resource group, Event Hub, Storage Account, and User Assigned Managed Identity—and configures IoT Hub message routing to both Event Hub and Storage Account endpoints with identity-based authentication. The configuration uses randomized Azure regions and CAF-compliant naming for uniqueness and best practices.
