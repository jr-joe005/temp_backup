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
  name = "sql-server-2019-capture-2"
  #name                = "sql-server-2019-3"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "nic-03" {
  name                = "nic-03"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic-04" {
  name                = "nic-04"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm-03" {
  name                  = "vm03"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic-03.id]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    id = data.azurerm_image.img.id
    #    publisher = "microsoftsqlserver"
    #    offer     = "sql2019-ws2019"
    #    sku       = "sqldev-gen2"
    #    version   = "latest"
  }

  storage_os_disk {
    name              = "os-disk-03"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"

    os_type = "Windows"
  }

  storage_data_disk {
    lun           = 0
    create_option = "FromImage"
    name          = "data-disk-03"
    caching       = "ReadWrite"
    disk_size_gb  = 50
  }

  os_profile {
    computer_name  = "vm03"
    admin_username = "jr_joe"
    admin_password = "bbx2022+1234"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

resource "azurerm_mssql_virtual_machine" "mssql-vm-03" {
  virtual_machine_id               = azurerm_virtual_machine.vm-03.id
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
    #collation = "Japanese_CI_AS"
    collation = "Latin1_General_CI_AI"
  }
}

#resource "azurerm_windows_virtual_machine" "vm-04" {
#  name                = "vm04"
#  resource_group_name = data.azurerm_resource_group.rg.name
#  location            = data.azurerm_resource_group.rg.location
#  size                = "Standard_B2s"
#  admin_username      = "jr_joe"
#  admin_password      = "bbx2022+1234"
#  network_interface_ids = [
#    azurerm_network_interface.nic-04.id,
#  ]
#
#  os_disk {
#    caching              = "ReadWrite"
#    storage_account_type = "Standard_LRS"
#  }
#
##  source_image_id = data.azurerm_image.img.id
#  source_image_reference {
#    publisher = "microsoftsqlserver"
#    offer     = "sql2019-ws2019"
#    sku       = "sqldev-gen2"
#    version   = "latest"
#  }
#}
#
#resource "azurerm_managed_disk" "data-disk-04" {
#  name                 = "data-disk-04"
#  location             = data.azurerm_resource_group.rg.location
#  resource_group_name  = data.azurerm_resource_group.rg.name
#  storage_account_type = "Standard_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = "50"
#}
#
#resource "azurerm_virtual_machine_data_disk_attachment" "link-data-disk-vm-04" {
#  managed_disk_id    = azurerm_managed_disk.data-disk-04.id
#  virtual_machine_id = azurerm_windows_virtual_machine.vm-04.id
#  lun                = "0"
#  caching            = "ReadWrite"
#}
#
#resource "azurerm_mssql_virtual_machine" "mssql-vm-04" {
#  virtual_machine_id               = azurerm_windows_virtual_machine.vm-04.id
#  sql_license_type                 = "PAYG"
#  r_services_enabled               = true
#  sql_connectivity_port            = 1433
#  sql_connectivity_type            = "PRIVATE"
#  sql_connectivity_update_password = "bbx2022+1234"
#  sql_connectivity_update_username = "sa"
#
#  auto_patching {
#    day_of_week                            = "Sunday"
#    maintenance_window_duration_in_minutes = 60
#    maintenance_window_starting_hour       = 2
#  }
#
#  sql_instance {
#    collation = "Japanese_CI_AS"
#  }
#}