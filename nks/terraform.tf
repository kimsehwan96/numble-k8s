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

data "ncloud_server_image" "image" {
  filter {
    name = "product_name"
    values = ["ubuntu-20.04"]
  }
}

data "ncloud_server_product" "product" {
  server_image_product_code = data.ncloud_server_image.image.product_code

  filter {
    name = "product_type"
    values = [ "STAND" ]
  }

  filter {
    name = "cpu_count"
    values = [ 2 ]
  }

  filter {
    name = "memory_size"
    values = [ "8GB" ]
  }

  filter {
    name = "product_code"
    values = [ "SSD" ]
    regex = true
  }
}

resource "ncloud_nks_node_pool" "node_pool" {
  cluster_uuid   = ncloud_nks_cluster.cluster.uuid
  node_pool_name = "numble-node-pool"
  node_count     = 1
  product_code   = data.ncloud_server_product.product.product_code
  subnet_no      = ncloud_subnet.private_subnet_1.id
  autoscale {
    enabled = false
    min = 1
    max = 1
  }
}