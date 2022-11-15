# Create AKS resource group
resource "azurerm_resource_group" "resource_group" {
  location = var.resource_group_location
  name     = "${var.resource_group_name}-rg"
}

# Create AKS VNet
resource "azurerm_virtual_network" "virtual_network" {
  name =  "${var.cluster_name}-vnet"
  location = var.resource_group_location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space = [var.network_address_space]
}
 
resource "azurerm_subnet" "aks_subnet" {
  name = var.subnet_name
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes = [var.subnet_address_prefix]
}

# Create Log Analytics resources
resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "aks_log_analytics_workspace" {
  location            = var.log_analytics_workspace_location
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "aks_log_analytics_solution" {
  location              = azurerm_log_analytics_workspace.aks_log_analytics_workspace.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.aks_log_analytics_workspace.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks_log_analytics_workspace.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  location                         = azurerm_resource_group.resource_group.location
  name                             = var.cluster_name
  resource_group_name              = azurerm_resource_group.resource_group.name
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.kubernetes_version
  http_application_routing_enabled = true
  tags                             = {
    Environment = "Development"
  }

  default_node_pool {
    name                 = "agentpool"
    vm_size              = "Standard_B2s"
    node_count           = var.agent_count
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }
  
  oms_agent {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_log_analytics_workspace.id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }
}