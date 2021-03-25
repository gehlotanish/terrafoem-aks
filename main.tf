provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "demo" {
  name     = "${var.prefix}-rg"
  location = var.location
}

module "ssh-key" {
  source         = "./modules/ssh-key"
  public_ssh_key = var.public_ssh_key == "" ? "" : var.public_ssh_key
}

resource "azurerm_virtual_network" "demo" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "demo" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.demo.name
  resource_group_name  = azurerm_resource_group.demo.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "demo" {
  name                    = "${var.prefix}-aks"
  location                = azurerm_resource_group.demo.location
  resource_group_name     = azurerm_resource_group.demo.name
  dns_prefix              = "${var.prefix}-aks"
  kubernetes_version      = "1.18.10"
  private_cluster_enabled = false

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = replace(var.public_ssh_key == "" ? module.ssh-key.public_ssh_key : var.public_ssh_key, "\n", "")

    }
  }

  default_node_pool {
    orchestrator_version = "1.18.10"
    name                 = "default"
    node_count           = 2
    vm_size              = var.vm_size
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    availability_zones   = ["1", "2"]
    min_count            = 2
    max_count            = 20
    max_pods             = 50
    enable_auto_scaling  = true
    vnet_subnet_id       = azurerm_subnet.demo.id
  }


  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    network_policy     = "azure"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.0.0.0/24"
    outbound_type      = "loadBalancer"
  }

  tags = {
    Environment = "Development"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  orchestrator_version  = "1.18.10"
  node_count            = 2
  vm_size               = var.vm_size
  os_disk_size_gb       = 30
  availability_zones    = ["1", "2"]
  min_count             = 2
  max_count             = 20
  max_pods              = 50
  enable_auto_scaling   = true
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.demo.id
  vnet_subnet_id        = azurerm_subnet.demo.id
}
