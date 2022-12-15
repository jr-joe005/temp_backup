provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = "tmp_bbx_jr"
}

data "azurerm_virtual_network" "vnet" {
  name                = "tmp_bbx_jr-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "snet" {
  name                 = "default"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_image" "img" {
  name                = "sql-server-2019"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm04" {
  name                  = "vm04"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    id = data.azurerm_image.img.id
  }

  storage_os_disk {
    name              = "os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"

    os_type = "Windows"
  }

  storage_data_disk {
    lun           = 0
    create_option = "FromImage"
    name          = "data-disk"
    caching       = "ReadWrite"
    disk_size_gb  = 1024
  }

  os_profile {
    computer_name  = "vm04"
    admin_username = "jr_joe"
    admin_password = "bbx2022+1234"
  }

  os_profile_windows_config {}
}

resource "azurerm_mssql_virtual_machine" "mssql-vm" {
  virtual_machine_id               = azurerm_virtual_machine.vm04.id
  sql_license_type                 = "PAYG"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = "bbx2022+1234"
  sql_connectivity_update_username = "sa"

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }

  sql_instance {
    collation = "Japanese_CI_AS"
  }
}