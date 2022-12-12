packer {
  required_plugins {
    windows-update = {
      version = "0.14.1"
      source = "github.com/rgl/windows-update"
    }
  }
}

variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type    = string
  default = ""
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "location" {
  type    = string
  default = ""
}

variable "date_string" {
  type    = string
  default = ""
}

# locals {
#   date_string = formatdate("YYYY-MM-DD-hhmm", timestamp())
# }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "azure-arm" "windows" {
  client_id                         = "${var.client_id}"
  client_secret                     = "${var.client_secret}"
  communicator                      = "winrm"
  disk_caching_type                 = "ReadWrite"
  image_offer                       = "sql2019-ws2019"
  image_publisher                   = "MicrosoftSQLServer"
  # image_sku                         = "standard-gen2" # use this when production.
  image_sku                         = "sqldev-gen2" # free license
  image_version                     = "15.0.221108"
  location                          = "${var.location}"
  managed_image_name                = "SQL-Server-2019_${var.date_string}"
  managed_image_resource_group_name = "${var.resource_group_name}"
  os_type                           = "Windows"
  subscription_id                   = "${var.subscription_id}"
  tenant_id                         = "${var.tenant_id}"
  vm_size                           = "Standard_B2s"
  temp_compute_name                 = "packer-vm01"
  winrm_insecure                    = true
  winrm_timeout                     = "20m"
  winrm_use_ssl                     = true
  winrm_username                    = "packer"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.azure-arm.windows"]


  provisioner "windows-shell" {
    script = "./scripts/rebuild_database.cmd.cmd"
  }

  provisioner "powershell" {
    script = "./scripts/sysprep.ps1"
  }

}
