output "rancher_server_id" {
  value = "${azurerm_virtual_machine.rancher-server.id}"
}

output "rancher_server_ip" {
  value = "${data.azurerm_public_ip.rancher-server-public-ip.ip_address}",
}

output "rancher_server_port" {
  value = "${var.rancher_server_port}"
}

output "rancher_api_url" {
  value = "http://${data.azurerm_public_ip.rancher-server-public-ip.ip_address}:${var.rancher_server_port}"
}