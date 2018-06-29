# Create network interface rancher server
resource "azurerm_network_interface" "rancher-server-inet" {
  location = "${var.location}"
  name = "${var.resource_prefix_name}-${var.rancher_server_name}-inet"
  resource_group_name = "${var.resource_group_name}"

  "ip_configuration" {
    name = "${var.resource_prefix_name}-${var.rancher_server_name}-inet-ip-conf"
    private_ip_address_allocation = "static"
    private_ip_address = "${var.rancher_server_private_ip}"
    subnet_id = "${var.subnet_id}"
  }
}


# Create specific security rules for Rancher server HTTPS 443 (internal)
resource "azurerm_network_security_rule" "rancher-server-security-rule-web-internal-443" {

  access = "Allow"
  destination_address_prefix = "${azurerm_network_interface.rancher-server-inet.private_ip_address}"
  destination_port_range = "443"
  direction = "Inbound"
  name = "${var.rancher_server_name}-443-internal"
  network_security_group_name = "${var.security_group_name}"
  priority = 103
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "*"
  source_port_range = "*"

}

# Create specific security rules for Rancher server HTTP 80
resource "azurerm_network_security_rule" "rancher-server-security-rule-web-internal-80" {

  access = "Allow"
  destination_address_prefix = "${azurerm_network_interface.rancher-server-inet.private_ip_address}"
  destination_port_range = "80"
  direction = "Inbound"
  name = "${var.rancher_server_name}-80-internal"
  network_security_group_name = "${var.security_group_name}"
  priority = 104
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "*"
  source_port_range = "*"

}

# Create specific security rules for Rancher server HTTP 22
resource "azurerm_network_security_rule" "rancher-server-security-rule-ssh" {

  access = "Allow"
  destination_address_prefix = "${azurerm_network_interface.rancher-server-inet.private_ip_address}"
  destination_port_range = "22"
  direction = "Inbound"
  name = "${var.rancher_server_name}-22-internal"
  network_security_group_name = "${var.security_group_name}"
  priority = 104
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "*"
  source_port_range = "*"

}

# create managed disk for rancher server vm
resource "azurerm_managed_disk" "rancher-server-managed-disk" {
  create_option = "Empty"
  disk_size_gb = 32
  location = "${var.location}"
  name = "${var.resource_prefix_name}-${var.rancher_server_name}-managed-disk"
  resource_group_name = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
}


# Create vm rancher server
resource "azurerm_virtual_machine" "rancher-server" {
  delete_os_disk_on_termination = true
  location = "${var.location}"
  name = "${var.resource_prefix_name}-${var.rancher_server_name}"
  network_interface_ids = ["${azurerm_network_interface.rancher-server-inet.id}"]
  resource_group_name = "${var.resource_group_name}"
  vm_size = "${var.rancher_server_vm_size}"

  os_profile {
    admin_username = "${var.ssh_username}"
    computer_name = "${var.resource_prefix_name}-${var.rancher_server_name}"
  }


	plan {
		name= "cis-ubuntu1604-l1"
		product= "cis-ubuntu-linux-1604-v1-0-0-l1"
		publisher= "center-for-internet-security-inc"
	}

	storage_image_reference {
		publisher = "center-for-internet-security-inc"
		offer     = "cis-ubuntu-linux-1604-v1-0-0-l1"
		sku       = "cis-ubuntu1604-l1"
		version	  = "latest"
	}


  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.ssh_username}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_public_key_file_path}")}"
    }
  }

  "storage_os_disk" {
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
    name = "${var.resource_prefix_name}-${var.rancher_server_name}-osdisk1"
  }

  storage_data_disk {
    create_option = "Attach"
    disk_size_gb = "${azurerm_managed_disk.rancher-server-managed-disk.disk_size_gb}"
    lun = 1
    managed_disk_id = "${azurerm_managed_disk.rancher-server-managed-disk.id}"
    name = "${azurerm_managed_disk.rancher-server-managed-disk.name}"
  }


}




resource "azurerm_virtual_machine_extension" "provisionning" {
  name                 = "hostname"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_machine_name = "${azurerm_virtual_machine.rancher-server.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "hostname && uptime"
    }
SETTINGS

  tags {
    environment = "Production"
  }
}


