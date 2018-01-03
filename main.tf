# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create network interface rancher server
resource "azurerm_network_interface" "rancher-server-inet" {
  location = "${var.location}"
  name = "${var.resource_prefix_name}-${var.rancher_server_name}-inet"
  resource_group_name = "${var.resource_group_name}"

  "ip_configuration" {
    name = "${var.resource_prefix_name}-${var.rancher_server_name}-inet-ip-conf"
    private_ip_address_allocation = "static"
    private_ip_address = "${var.rancher_server_private_ip}"
    public_ip_address_id = "${azurerm_public_ip.rancher-server-public-ip.id}"
    subnet_id = "${var.subnet_id}"
  }
}


# Create specific security rules for Rancher server HTTPS 443
resource "azurerm_network_security_rule" "rancher-server-security-rule-web-external-443" {

  access = "Allow"
  destination_address_prefix = "${data.azurerm_public_ip.rancher-server-public-ip.ip_address}"
  destination_port_range = "443"
  direction = "Inbound"
  name = "${var.rancher_server_name}-443-external"
  network_security_group_name = "${var.security_group_name}"
  priority = 101
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "*"
  source_port_range = "*"

}

# Create specific security rules for Rancher server HTTP 80
resource "azurerm_network_security_rule" "rancher-server-security-rule-web-external-80" {

  access = "Allow"
  destination_address_prefix = "${data.azurerm_public_ip.rancher-server-public-ip.ip_address}"
  destination_port_range = "80"
  direction = "Inbound"
  name = "${var.rancher_server_name}-80-external"
  network_security_group_name = "${var.security_group_name}"
  priority = 102
  protocol = "Tcp"
  resource_group_name = "${var.resource_group_name}"
  source_address_prefix = "*"
  source_port_range = "*"

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

resource "azurerm_dns_a_record" "rancher-server-external-dns-record" {
  name = "${var.rancher_domain}"
  records = ["${data.azurerm_public_ip.rancher-server-public-ip.ip_address}"]
  resource_group_name = "${var.rancher_dns_zone_resource_group}"
  ttl = 300
  zone_name = "${var.rancher_dns_zone}"
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

# Create the rancher server public IP
resource "azurerm_public_ip" "rancher-server-public-ip" {
  location = "${var.location}"
  name = "${var.resource_prefix_name}-${var.rancher_server_name}-public-ip"
  public_ip_address_allocation = "Dynamic"
  resource_group_name = "${var.resource_group_name}"
}

# Retrieve rancher server public IP
data "azurerm_public_ip" "rancher-server-public-ip" {
  name = "${azurerm_public_ip.rancher-server-public-ip.name}"
  resource_group_name = "${var.resource_group_name}"
  depends_on = ["azurerm_virtual_machine.rancher-server"]
}

#

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

  storage_image_reference {
    id = "${var.rancher_sever_image_id}"
  }
}
