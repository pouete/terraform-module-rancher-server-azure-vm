output "rancher_server_id" {
  value = "${azurerm_virtual_machine.rancher-server.id}"
}

output "rancher_server_public_ip" {
  value = "${data.azurerm_public_ip.rancher-server-public-ip.ip_address}",
}

output "rancher_server_private_ip" {
  value = "${azurerm_network_interface.rancher-server-inet.private_ip_address}"
}

output "rancher_server_port" {
  value = "${var.rancher_server_port}"
}
