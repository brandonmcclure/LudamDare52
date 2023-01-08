# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }

  backend "s3" {
  	bucket = "terraform"
  	key = "ld52/terraform.tfstate"
  	endpoint = "https://minio.example.com"
  	skip_credentials_validation = true
  	skip_metadata_api_check = true
  	skip_region_validation = true
  	force_path_style = true
  	access_key = ""
  	secret_key = ""
  	region = "us-east-1" 
  }

}
provider "azurerm" {
  features {}
}


# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
  name     = "ld52"
  location = "eastus"

  tags = {
    environment = "Production"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = {
    environment = "Production"
  }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "myNIC"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }

  tags = {
    environment = "Production"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "anisgassoc" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.myterraformgroup.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.myterraformgroup.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Production"
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" {
  value     = tls_private_key.ssh_private_key.private_key_pem
  sensitive = true
}
resource "local_sensitive_file" "private_key" {
    content  = tls_private_key.ssh_private_key.private_key_pem
    filename = "private_key.pem"
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "myVM"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = "Standard_B1s"
  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "ld52"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_private_key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }
  # 	user_data = <<EOF
  # #!/bin/bash
  # echo "Copying the SSH Key Of Jenkins to the server"
  # echo -e "#Jenkins\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB*******************F/SNZPMT4Qm/RVgBbIhG8VsoDhGM0tgIzWyTaNxDPSDx/yzJ8FQwCKOH6YR3RugLvTU+jDKvI8BWOnMM5cgrbfKbBssUyJSdWI86py4bi05A3X6O5+6xS6IvQbZwlbJiu/DbgAcvGLiq1mDi77O+DvU22RNgCB9hGddryWc3nTDOMyVaex5EdfvgxEli1DAM2YYr/DdxVvdzkrP/1fol6t+XT4FeQyW/KcQuRA53qG0aSYlSN/6NUO3OGuLn jenkins@gritfy.com\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAPlhbcDQ06FO8euMxVvsglV4gqhD0v1l8h+bk/X+eJWqQMHZ0CXzsywTe+32zdu9JydbwiQiMIlDwFy0nsyX+quzLupYejrAtFFOKoFSzNB3ng69KSV+M6kUZdXHfP9PjYt5wZfOW0h/W9+2Oz406UjpeaW5t9XPftx784nLsocR3d7mosIgLMXkFLijOfJknhEKWxMmvkwV15fcuPfpRhvJkFDCmpFMBTaOwE2rDuj22r0Z4bI78CdtZgTSB5eK1YebOtEUllB+pwoMA40cNgnivd ubuntu@gritfy.com" >> /home/ubuntu/.ssh/authorized_keys
  # echo "Installing NodeExporter"
  # mkdir /home/ubuntu/node_exporter
  # cd /home/ubuntu/node_exporter
  # wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz
  # tar node_exporter-1.2.2.linux-amd64.tar.gz
  # cd node_exporter-1.2.2.linux-amd64
  # ./node_exporter 
  # EOF
  tags = {
    environment = "Production"
  }
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
