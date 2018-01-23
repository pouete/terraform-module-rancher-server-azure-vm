VM ready for rancher module
===========

A terraform module to provide a virtual machine ready to run a rancher server in AZURE.
It requires an existing network.
This module won't run the Rancher server

Module Input Variables
----------------------

## required

- `rancher_sever_image_id` - Virtual Machine Image ID for Rancher server
- `resource_group_name` - Resource group name from Azure
- `security_group_name` - Security group name on which to add security rules
- `ssh_private_key_file_path` - Absolute path to private SSH key
- `ssh_public_key_file_path` - Absolute path to public SSH key
- `subnet_address_prefix` - Subnet address prefix
- `subnet_id` - Subnet ID where to put Rancher server
- `vnet_address_space` - The address space that is used the virtual network

## Optional

- `location` - Azure location (Default = "West Europe")
- `rancher_server_name` - Rancher server name (Default = "server")
- `rancher_server_port` - Port on which Rancher server will listen (Default = 8080)
- `rancher_server_private_ip` - Rancher server private IP (Default = "10.3.1.4")
- `rancher_server_vm_size` - Rancher server VM size on Azure (Default = "Standard_DS1_v2")
- `resource_prefix_name` - Prefix to add on each resource name (Default = "")
- `ssh_username` - SSH username (Default = "rancher")

Usage
-----

```hcl
module "rancher_server" {
  source = "github.com/nespresso/terraform-module-rancher-server-azure-vm"

  rancher_sever_image_id = "/subscriptions/XXXX/resourceGroups/resource-group/providers/Microsoft.Compute/images/Rancher-Image"
  resource_group_name = "resource-group"
  security_group_name = "rancher-subnet-front-nsg"
  ssh_private_key_file_path = "/home/username/.ssh/id_rsa"
  ssh_public_key_file_path = "/home/username.ssh/id_rsa.pub"
  subnet_address_prefix = "10.3.1.0/24"
  subnet_id = "/subscriptions/XXXX/resourceGroups/resource-group/providers/Microsoft.Network/virtualNetworks/prefix-vnet/subnets/prefix-subnet"
  vnet_address_space = "10.3.0.0/16"
}
```

Tested only with `Terraform v0.11.0` and `provider.azurerm v0.3.3`, which doesn't mean it won't work with other versions.

Outputs
=======

 - `rancher_server_id` - Rancher server ID
 - `rancher_server_public_ip` - Rancher server public IP
 - `rancher_server_private_ip` - Rancher server private IP
 - `rancher_server_port` - Rancher server port

Authors
=======

nicolas.cheutin@nestle.com