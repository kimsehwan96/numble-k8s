terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

// Configure the ncloud provider
provider "ncloud" {
    support_vpc = true
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

// Create a new server instance
resource "ncloud_vpc" "vpc" {
    ipv4_cidr_block = "10.0.0.0/16"
}

// Create private and public subnets
resource "ncloud_subnet" "public_subnet_1" {
    vpc_no = ncloud_vpc.vpc.id
    subnet = "10.0.100.0/24"
    zone = "KR-1"
    name = "public-subnet-1"
    network_acl_no = ncloud_vpc.vpc.default_network_acl_no
    subnet_type = "PUBLIC"
    usage_type = "GEN"
}
resource "ncloud_subnet" "private_subnet_1" {
    vpc_no = ncloud_vpc.vpc.id
    subnet = "10.0.1.0/24"
    zone = "KR-1"
    name = "private-subnet-1"
    network_acl_no = ncloud_vpc.vpc.default_network_acl_no
    subnet_type = "PRIVATE"
    usage_type = "GEN"
}

resource "ncloud_subnet" "private_subnet_load_balancer_1" {
    vpc_no = ncloud_vpc.vpc.id
    subnet = "10.0.200.0/24"
    zone = "KR-1"
    name = "private-subnet-lb-1"
    network_acl_no = ncloud_vpc.vpc.default_network_acl_no
    subnet_type = "PRIVATE"
    usage_type = "LOADB"
}

resource "ncloud_login_key" "loginkey" {
  key_name = "numble-cluster-login-key"
}

data "ncloud_server_image" "image" {
  filter {
    name = "product_name"
    values = ["ubuntu-20.04"]
  }
}

data "ncloud_server_product" "worker" {
  server_image_product_code = data.ncloud_server_image.image.product_code

  filter {
    name = "product_type"
    values = [ "STAND" ]
  }

  filter {
    name = "cpu_count"
    values = [ 4 ]
  }

  filter {
    name = "memory_size"
    values = [ "16GB" ]
  }

  filter {
    name = "product_code"
    values = [ "SSD" ]
    regex = true
  }
}

// kubernetes cluster

data "ncloud_nks_versions" "version" {
  filter {
    name = "value"
    values = ["1.24"]
    regex = true
  }
}

resource "ncloud_nks_cluster" "cluster" {
  cluster_type           = "SVR.VNKS.STAND.C002.M008.NET.SSD.B050.G002"
  k8s_version            = data.ncloud_nks_versions.version.versions.0.value
  login_key_name         = ncloud_login_key.loginkey.key_name
  name                   = "my-cluster"
  lb_private_subnet_no   = ncloud_subnet.private_subnet_load_balancer_1.id
  kube_network_plugin    = "cilium"
  subnet_no_list         = [ ncloud_subnet.private_subnet_1.id ]
  vpc_no                 = ncloud_vpc.vpc.id
  zone                   = "KR-1"
  log {
    audit = true
  }
}


resource "ncloud_nks_node_pool" "node_pool" {
  cluster_uuid   = ncloud_nks_cluster.cluster.uuid
  node_pool_name = "numble-node-pool"
  node_count     = 1
  product_code   = data.ncloud_server_product.worker.product_code
  subnet_no      = ncloud_subnet.private_subnet_1.id
  autoscale {
    enabled = false
    min = 1
    max = 1
  }
}


// Creat NAT Gateway for K8s Worker node on private subnet to access internet

resource "ncloud_nat_gateway" "nat_gateway" {
  vpc_no = ncloud_vpc.vpc.id
  zone = "KR-1"
}

resource "ncloud_route" "nat_route" {
  destination_cidr_block = "0.0.0.0/0"
  target_type = "NATGW"
  target_name = ncloud_nat_gateway.nat_gateway.name
  target_no = ncloud_nat_gateway.nat_gateway.id
  route_table_no = ncloud_vpc.vpc.default_private_route_table_no
}


// for bastion server

resource "ncloud_network_interface" "bastion_network_interface" {
  name = "bastion-network-interface"
  description = "bastion network interface"
  subnet_no = ncloud_subnet.public_subnet_1.id
  access_control_groups = [
    ncloud_nks_cluster.cluster.acg_no,
    ncloud_vpc.vpc.default_access_control_group_no
    ]
}

resource "ncloud_server" "bastion" {
  subnet_no = ncloud_subnet.public_subnet_1.id
  name = "numble-bastion-server"
  server_image_product_code = data.ncloud_server_image.image.product_code
  login_key_name = ncloud_login_key.loginkey.key_name
  network_interface {
    network_interface_no = ncloud_network_interface.bastion_network_interface.id
    order = 0
  }
}

resource "ncloud_public_ip" "bastion_public_ip" {
  server_instance_no = ncloud_server.bastion.instance_no
}

