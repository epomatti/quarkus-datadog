terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.30.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.0.0"
    }
  }
}

resource "azapi_resource" "container_app" {
  name      = var.name
  location  = var.location
  parent_id = var.group_id
  type      = "Microsoft.App/containerApps@2022-03-01"

  response_export_values = ["properties.configuration.ingress.fqdn"]

  body = jsonencode({
    properties : {
      managedEnvironmentId = var.environment
      configuration = {
        ingress = {
          external   = var.external
          targetPort = var.ingress_target_port
        }
      }
      template = {
        containers = [
          {
            name  = var.name
            image = var.container_image
            resources = {
              cpu    = var.cpu
              memory = var.memory
            }
            env = var.container_envs
            # probes = [
            #   {
            #     type = "Liveness"
            #     httpGet = {
            #       path = "/liveness"
            #       port = var.ingress_target_port
            #       httpHeaders = [
            #         {
            #           name  = "Custom-Header"
            #           value = "Awesome"
            #         }
            #       ]
            #     }
            #     initialDelaySeconds = 3
            #     periodSeconds       = 3
            #   }
            # ]
          }
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 2
        }
      }
    }
  })
}
