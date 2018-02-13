output "rancher_server_id" {
  value = "${azurerm_virtual_machine.rancher-server.id}"
}

output "rancher_server_ip" {
  value = "${data.azurerm_public_ip.rancher-server-public-ip.ip_address}",
}

output "rancher_domain" {
  value = "${var.rancher_domain}"
}

output "rancher_fqdn" {
  value = "${var.rancher_domain}.${var.rancher_dns_zone}"
}

output "rancher_api_url" {
  value = "https://${var.rancher_domain}.${var.rancher_dns_zone}"
}
