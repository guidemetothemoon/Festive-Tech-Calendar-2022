# Initial branch commit

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

# Deploy Log Analytics
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "log-${random_pet.primary.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
}

# Deploy AKS

#Obtain latest AKS Version details
data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.rg.location
}

#Create Azure AD Group for AKS Management
resource "azuread_group" "aks_administrators" {
  display_name = "${local.aks_cluster_name}-administrators"
  security_enabled = true
  description = "Kubernetes administrators for the ${local.aks_cluster_name} cluster."
}

#Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  dns_prefix          = local.aks_cluster_name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  location            = azurerm_resource_group.rg.location
  name                = local.aks_cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  node_resource_group = local.aks_node_resource_group

  default_node_pool {
    zones = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = 3
    min_count            = 1
    name                 = "system"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    os_disk_size_gb      = 1024
    vm_size              = "Standard_DS2_v2"
    only_critical_addons_enabled = true
  }

  azure_policy_enabled = true
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  }

  identity { type = "SystemAssigned" }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = [azuread_group.aks_administrators.object_id]
  }
}

#Create workload (user) node pool
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  zones                 = [1, 2, 3]
  enable_auto_scaling   = true
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  name                  = "workload"
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  os_disk_size_gb       = 1024
  vm_size               = "Standard_DS2_v2"
}


# Random
resource "random_pet" "primary" {}