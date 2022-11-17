# Create AKS resource group - Primary
resource "azurerm_resource_group" "resource_group_primary" {
  location = var.resource_group_location_primary
  name     = "rg-${var.resource_group_name}-${var.resource_group_location_primary}"
}

# Create AKS resource group - Secondary
resource "azurerm_resource_group" "resource_group_secondary" {
  location = var.resource_group_location_secondary
  name     = "rg-${var.resource_group_name}-${var.resource_group_location_secondary}"
}

#Create Azure AD Group for AKS Management
resource "azuread_group" "aks_administrators" {
  display_name     = "${var.cluster_name}-administrators"
  security_enabled = true
  description      = "Kubernetes administrators for the ${var.cluster_name} cluster."
}

# Create AKS VNet - Primary
resource "azurerm_virtual_network" "virtual_network_primary" {
  name                = "vnet-${var.cluster_name}-${var.resource_group_location_primary}"
  location            = var.resource_group_location_primary
  resource_group_name = azurerm_resource_group.resource_group_primary.name
  address_space       = [var.network_address_space]
}


resource "azurerm_subnet" "aks_subnet_primary" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.resource_group_primary.name
  virtual_network_name = azurerm_virtual_network.virtual_network_primary.name
  address_prefixes     = [var.subnet_address_prefix]
}

# Create AKS VNet - Secondary
resource "azurerm_virtual_network" "virtual_network_secondary" {
  name                = "vnet-${var.cluster_name}-${var.resource_group_location_secondary}"
  location            = var.resource_group_location_secondary
  resource_group_name = azurerm_resource_group.resource_group_secondary.name
  address_space       = [var.network_address_space]
}

resource "azurerm_subnet" "aks_subnet_secondary" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.resource_group_secondary.name
  virtual_network_name = azurerm_virtual_network.virtual_network_secondary.name
  address_prefixes     = [var.subnet_address_prefix]
}

# Create Log Analytics resources - Primary
resource "random_id" "log_analytics_workspace_name_suffix_primary" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "aks_log_analytics_workspace_primary" {
  location            = var.resource_group_location_primary
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix_primary.dec}"
  resource_group_name = azurerm_resource_group.resource_group_primary.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "aks_log_analytics_solution_primary" {
  location              = azurerm_log_analytics_workspace.aks_log_analytics_workspace_primary.location
  resource_group_name   = azurerm_resource_group.resource_group_primary.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.aks_log_analytics_workspace_primary.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks_log_analytics_workspace_primary.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

# Create Log Analytics resources - Secondary
resource "random_id" "log_analytics_workspace_name_suffix_secondary" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "aks_log_analytics_workspace_secondary" {
  location            = var.resource_group_location_secondary
  name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix_secondary.dec}"
  resource_group_name = azurerm_resource_group.resource_group_secondary.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "aks_log_analytics_solution_secondary" {
  location              = azurerm_log_analytics_workspace.aks_log_analytics_workspace_secondary.location
  resource_group_name   = azurerm_resource_group.resource_group_secondary.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.aks_log_analytics_workspace_secondary.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks_log_analytics_workspace_secondary.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

# AKS Cluster - Primary
resource "azurerm_kubernetes_cluster" "aks_primary" {
  location                         = azurerm_resource_group.resource_group_primary.location
  name                             = "${var.cluster_name}-${var.resource_group_location_primary}"
  resource_group_name              = azurerm_resource_group.resource_group_primary.name
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.kubernetes_version
  node_resource_group              = "rg-node-${var.cluster_name}-${var.resource_group_location_primary}"
  http_application_routing_enabled = true
  tags = {
    Environment = "Development"
  }

  default_node_pool {
    name                 = "agentpool"
    vm_size              = "Standard_B2s"
    node_count           = var.agent_count
    vnet_subnet_id       = azurerm_subnet.aks_subnet_primary.id
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_log_analytics_workspace_primary.id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  identity { type = "SystemAssigned" }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = [azuread_group.aks_administrators.object_id]
  }
}

# AKS Cluster - Secondary
resource "azurerm_kubernetes_cluster" "aks_secondary" {
  location                         = azurerm_resource_group.resource_group_secondary.location
  name                             = "${var.cluster_name}-${var.resource_group_location_secondary}"
  resource_group_name              = azurerm_resource_group.resource_group_secondary.name
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.kubernetes_version
  node_resource_group              = "rg-node-${var.cluster_name}-${var.resource_group_location_secondary}"
  http_application_routing_enabled = true
  tags = {
    Environment = "Development"
  }

  default_node_pool {
    name                 = "agentpool"
    vm_size              = "Standard_B2s"
    node_count           = var.agent_count
    vnet_subnet_id       = azurerm_subnet.aks_subnet_secondary.id
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_log_analytics_workspace_secondary.id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  identity { type = "SystemAssigned" }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = [azuread_group.aks_administrators.object_id]
  }
}
