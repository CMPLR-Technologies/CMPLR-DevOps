# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "cmplr_rg" {
    name     = "cmplr_rg"
    location = "eastus"

    tags = {
        environment = "Application deployment"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "cmplr_vnet" {
    name                = "cmplr_vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.cmplr_rg.name

    tags = {
        environment = "Application Deployment"
    }
}

# Create subnet
resource "azurerm_subnet" "cmplr_subnet" {
    name                 = "cmplr_subnet"
    resource_group_name  = azurerm_resource_group.cmplr_rg.name
    virtual_network_name = azurerm_virtual_network.cmplr_vnet.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "cmplr_ip" {
    name                         = "cmplr_ip"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.cmplr_rg.name
    allocation_method            = "Dynamic" //Dynamic Public IP Addresses aren't allocated until they're assigned to a resource 
                                            //(such as a Virtual Machine or a Load Balancer) by design within Azure -

    tags = {
        environment = "Application Deployment"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "cmplr_sg" {
    name                = "cmplr_sg"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.cmplr_rg.name


    ///To allow ssh
    security_rule {
        name                       = "SSH"
        priority                   = 1001  //if you had an inbound rule that allowed TCP traffic on Port 80 with a priority of 250
                                            //and another that denied TCP traffic on Port 80 with a priority of 125, 
                                            //the NSG rule of deny would be put in place. This is because the “deny rule”,
                                            // with a priority of 125 is closer to 100 than the “allow rule”, containing a priority of 250.
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    ///To allow Jenkins
    security_rule {
        name                       = "jenkins"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    ///To allow prometheus
    security_rule {
        name                       = "prometheus"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9090"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    ///To allow grafana
    security_rule {
        name                       = "grafana"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3000"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


    ///To allow access to the internet
    security_rule {
        name                       = "outter"
        priority                   = 1001
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


    //Any future modifications are put here


    tags = {
        environment = "Application Deployment"
    }
}

# Create network interface
resource "azurerm_network_interface" "cmplr_NIC" {
    name                      = "cmplr_NIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.cmplr_rg.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.cmplr_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.cmplr_ip.id
    }

    tags = {
        environment = "Application Deployment"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.cmplr_NIC.id
    network_security_group_id = azurerm_network_security_group.cmplr_sg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.cmplr_rg.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.cmplr_rg.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Application Deployment"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "cmplr_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.cmplr_key.private_key_pem 
    sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "cmplrmaster" {
    name                  = "cmplrmaster"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.cmplr_rg.name
    network_interface_ids = [azurerm_network_interface.cmplr_NIC.id]
    size                  = "Standard_D2as_v4"  //the most suitable instance

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts"
        version   = "latest"
    }

    computer_name  = "cmplrmaster"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.cmplr_key.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Application Deployment"
    }
}

//The null resource is to sort execution of the file provisioner as it needs to wait for booth aws_eip and aws_instance to be created
//We can not but this inside the instance and depend on the aws_eip as it (the aws_eip) already depends on the instance
resource "null_resource" "master-null" {
 depends_on = [
    azurerm_public_ip.cmplr_ip,
   azurerm_linux_virtual_machine.cmplrmaster
 ] 
//Run the configuration sript for the created instance : install git, docker, jenkins, terraform (so he can provision other instances)
# Copy in the bash script we want to execute.
  # The source is the location of the bash script
  # on the local linux box you are executing terraform
  # from.  The destination is on the new AWS instance.
  
  #Create connection with the provisioned instance
  connection {
    type    = "ssh"
    user = "azureuser"
    private_key = tls_private_key.cmplr_key.private_key_pem
    host = azurerm_linux_virtual_machine.cmplrmaster.public_ip_address
  }

  #Copy the bash script file
  provisioner "file" {
    source      = "./master.sh"
    destination = "/tmp/master.sh"
  }
  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/master.sh",
      "sudo /tmp/master.sh",
    ]
  }
}
