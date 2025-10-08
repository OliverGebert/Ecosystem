terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# -------------------------------
# 1. Resource Group
# -------------------------------
resource "azurerm_resource_group" "fastapi_rg" {
  name     = "rg-fastapi-app"
  location = "westeurope"
}

# -------------------------------
# 2. Random suffix for uniqueness
# -------------------------------
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# -------------------------------
# 3. Azure Container Registry (ACR)
# -------------------------------
resource "azurerm_container_registry" "fastapi_acr" {
  name                = "fastapiacr${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.fastapi_rg.name
  location            = azurerm_resource_group.fastapi_rg.location
  sku                 = "Basic"
  admin_enabled       = false # prefer managed identity for security
}

# -------------------------------
# 4. App Service Plan (Linux)
# -------------------------------
resource "azurerm_service_plan" "fastapi_plan" {
  name                = "asp-fastapi"
  resource_group_name = azurerm_resource_group.fastapi_rg.name
  location            = azurerm_resource_group.fastapi_rg.location
  os_type             = "Linux"
  sku_name            = "B1" # Basic tier; upgrade to S1 or higher for production
}

# -------------------------------
# 5. Managed Identity for the Web App
# -------------------------------
resource "azurerm_user_assigned_identity" "fastapi_identity" {
  name                = "id-fastapi-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.fastapi_rg.name
  location            = azurerm_resource_group.fastapi_rg.location
}

# -------------------------------
# 6. Web App for Containers
# -------------------------------
resource "azurerm_linux_web_app" "fastapi_app" {
  depends_on = [time_sleep.wait_for_role_assignment]
  name                = "fastapi-webapp-${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.fastapi_rg.name
  location            = azurerm_resource_group.fastapi_rg.location
  service_plan_id     = azurerm_service_plan.fastapi_plan.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.fastapi_identity.id]
  }

  site_config {
    # Tell Azure what Docker image to run and which identity to use
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.fastapi_identity.client_id
    application_stack {
      docker_image_name   = "fastapi:latest"
      docker_registry_url = "https://${azurerm_container_registry.fastapi_acr.login_server}"
    }
  }

  app_settings = {
    # Port your FastAPI app listens on (e.g., uvicorn --port 8000)
    "WEBSITES_PORT" = "8000"

    # Optional environment variables for your app
    "ENV" = "production"
  }
}

# -------------------------------
# 7. Give Web App permission to pull from ACR
# -------------------------------
resource "azurerm_role_assignment" "acr_pull_role" {
  scope                = azurerm_container_registry.fastapi_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.fastapi_identity.principal_id
}

# -------------------------------
# 7b. Wait to ensure role assignment is active
# -------------------------------
resource "time_sleep" "wait_for_role_assignment" {
  depends_on = [azurerm_role_assignment.acr_pull_role]
  create_duration = "60s"
}

# -------------------------------
# 8. Terraform output to local .env file for Make
# -------------------------------

resource "local_file" "env_file" {
  content = <<EOT
RESOURCE_GROUP=${azurerm_resource_group.fastapi_rg.name}
ACR_NAME=${azurerm_container_registry.fastapi_acr.name}
ACR_LOGIN=${azurerm_container_registry.fastapi_acr.login_server}
WEBAPP_NAME=${azurerm_linux_web_app.fastapi_app.name}
WEBAPP_URL=${azurerm_linux_web_app.fastapi_app.default_hostname}
EOT

  filename = "${path.module}/.env"
}

# -------------------------------
# 9. Terraform Console Outputs
# -------------------------------

output "resource_group_name" {
  description = "Name of the resource group (useful for Makefile deploys)"
  value       = azurerm_resource_group.fastapi_rg.name
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.fastapi_acr.name
}

output "acr_login_server" {
  description = "ACR login server for tagging and pushing images"
  value       = azurerm_container_registry.fastapi_acr.login_server
}

output "webapp_name" {
  description = "Public URL of your FastAPI app"
  value       = azurerm_linux_web_app.fastapi_app.name
}

output "webapp_url" {
  description = "Public URL of your FastAPI app"
  value       = azurerm_linux_web_app.fastapi_app.default_hostname
}

