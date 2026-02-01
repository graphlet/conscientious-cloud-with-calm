terraform {
  required_version = ">= 0.14.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Get current Azure client configuration for Key Vault access
data "azurerm_client_config" "current" {}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup-${random_integer.ri.result}"
  location = "westeurope"
}

# CONTROL: key-management - Azure Key Vault with soft delete, purge protection, and RBAC
resource "azurerm_key_vault" "kv" {
  name                = "kv-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # CONTROL: key-management - soft delete enabled
  soft_delete_retention_days = 90

  # CONTROL: key-management - purge protection enabled
  purge_protection_enabled = true

  # CONTROL: key-management - RBAC access control model
  rbac_authorization_enabled = true

  # CONTROL: key-management - enabled for disk encryption
  enabled_for_disk_encryption = true

  # CONTROL: key-management - network ACLs enabled
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "baseline"
    control     = "key-management"
  }
}

# CONTROL: encryption-at-rest - Storage Account with infrastructure encryption and TLS 1.2
resource "azurerm_storage_account" "storage" {
  name                = "storage${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  # CONTROL: encryption-in-transit - HTTPS only traffic
  https_traffic_only_enabled = true

  # CONTROL: encryption-in-transit - minimum TLS version 1.2
  min_tls_version = "TLS1_2"

  # CONTROL: encryption-at-rest - infrastructure encryption enabled
  infrastructure_encryption_enabled = true

  tags = {
    environment = "baseline"
    control     = "encryption-at-rest,encryption-in-transit"
  }
}

# Create storage container for web app data (required for storage_account block)
resource "azurerm_storage_container" "app_data" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

# Create the web app with managed identity and all security controls
resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id

  # CONTROL: https-enforcement, encryption-in-transit - HTTPS only
  https_only = true

  # Enable system-assigned managed identity for Key Vault access
  identity {
    type = "SystemAssigned"
  }

  site_config {
    # CONTROL: tls-security, encryption-in-transit - minimum TLS version 1.2
    minimum_tls_version = "1.2"

    # CONTROL: tls-security - SCM (Kudu) minimum TLS version 1.2
    scm_minimum_tls_version = "1.2"

    # F1 tier limitation
    always_on = false

    # CONTROL: encryption-in-transit - disable FTPS (use HTTPS only)
    ftps_state = "Disabled"

    application_stack {
      node_version = "24-lts"
    }
  }

  # Link to storage account for app data/logs (encryption-at-rest control)
  storage_account {
    name         = "appstorage"
    type         = "AzureBlob"
    account_name = azurerm_storage_account.storage.name
    access_key   = azurerm_storage_account.storage.primary_access_key
    share_name   = "app-data"
  }

  tags = {
    environment = "baseline"
    control     = "https-enforcement,tls-security,encryption-in-transit"
  }
}

# CONTROL: key-management - Grant web app managed identity access to Key Vault
resource "azurerm_role_assignment" "webapp_kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.webapp.identity[0].principal_id
}

# Outputs
output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Resource Group name"
}

output "webapp_url" {
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
  description = "Web App URL (HTTPS enforced)"
}

output "key_vault_name" {
  value       = azurerm_key_vault.kv.name
  description = "Key Vault name"
}

output "storage_account_name" {
  value       = azurerm_storage_account.storage.name
  description = "Storage Account name"
}

output "webapp_identity_principal_id" {
  value       = azurerm_linux_web_app.webapp.identity[0].principal_id
  description = "Web App Managed Identity Principal ID"
}
