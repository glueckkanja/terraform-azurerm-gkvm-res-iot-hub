resource "azapi_resource" "this" {
  body = {
    etag = "AAAAABUAAAA="
    properties = {
      allowedFqdnList = []
      cloudToDevice = {
        defaultTtlAsIso8601 = "PT1H"
        feedback = {
          lockDurationAsIso8601 = "PT1M"
          maxDeliveryCount      = 10
          ttlAsIso8601          = "PT1H"
        }
        maxDeliveryCount = 10
      }
      disableLocalAuth              = false
      enableDataResidency           = false
      enableFileUploadNotifications = false
      eventHubEndpoints = {
        events = {
          partitionCount      = 2
          retentionTimeInDays = 1
        }
      }
      features      = "RootCertificateV2"
      ipFilterRules = []
      messagingEndpoints = {
        fileNotifications = {
          lockDurationAsIso8601 = "PT1M"
          maxDeliveryCount      = 10
          ttlAsIso8601          = "PT1H"
        }
      }
      networkRuleSets = {
        applyToBuiltInEventHubEndpoint = false
        defaultAction                  = "Deny"
        ipRules = [{
          action     = "Allow"
          filterName = "CNSOU"
          ipMask     = "222.92.26.240/29"
          }, {
          action     = "Allow"
          filterName = "DELIN-Soco"
          ipMask     = "212.16.235.176/28"
          }, {
          action     = "Allow"
          filterName = "DELIN-TSI"
          ipMask     = "93.122.78.208/28"
          }, {
          action     = "Allow"
          filterName = "DELIN-TSI2"
          ipMask     = "93.122.84.0/26"
          }, {
          action     = "Allow"
          filterName = "AEDUB-1"
          ipMask     = "83.110.8.80/29"
          }, {
          action     = "Allow"
          filterName = "AEDUB-2"
          ipMask     = "151.253.2.208/29"
        }]
      }
      privateEndpointConnections = [{
        properties = {
          privateEndpoint = {}
          privateLinkServiceConnectionState = {
            actionsRequired = "None"
            description     = "Auto-Approved"
            status          = "Approved"
          }
        }
      }]
      publicNetworkAccess = "Enabled"
      rootCertificate = {
        enableRootCertificateV2 = true
      }
      routing = {
        endpoints = {
          cosmosDBSqlContainers = []
          eventHubs             = []
          serviceBusQueues      = []
          serviceBusTopics      = []
          storageContainers     = []
        }
        fallbackRoute = {
          condition     = "true"
          endpointNames = ["events"]
          isEnabled     = true
          name          = "$fallback"
          source        = "DeviceMessages"
        }
        routes = []
      }
      storageEndpoints = {
        "$default" = {
          connectionString = ""
          containerName    = ""
          sasTtlAsIso8601  = "PT1H"
        }
      }
    }
    sku = {
      capacity = 1
      name     = "S1"
    }
  }
  location  = "germanywestcentral"
  name      = "iot-centraldtp-dev-gwc"
  parent_id = "/subscriptions/dabee6fb-7ec1-41f8-bff3-be98be448af9/resourceGroups/rg-centraldtp-nonprd-gwc"
  tags = {
    "business unit"             = "Global"
    "demand id"                 = "Project Athena"
    "external contact"          = "max.vasterd@paconsulting.com / maureen.xu@paconsulting.com"
    "it application contact"    = "Pathan, Parveena"
    "it infrastructure contact" = "SIG IT MS"
    purpose                     = "Central Data Platform PoC for Project Athena"
    "service owner"             = "Pathan, Parveena"
    severity                    = "Medium"
    "site name"                 = "Global"
    stage                       = "Test"
    "temp cost category"        = "New Demand"
    "ticket id"                 = "None"
  }
  type = "Microsoft.Devices/IotHubs@2023-06-30-preview"
  identity {
    type = "None"
  }
}
