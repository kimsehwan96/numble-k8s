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

resource "ncloud_subnet" "private_subnet_2" {
    vpc_no = ncloud_vpc.vpc.id
    subnet = "10.0.2.0/24"
    zone = "KR-2"
    name = "private-subnet-2"
    network_acl_no = ncloud_vpc.vpc.default_network_acl_no
    subnet_type = "PRIVATE"
    usage_type = "GEN"
}

resource "ncloud_subnet" "public_subnet_1" {
    vpc_no = ncloud_vpc.vpc.id
    subnet = "10.0.3.0/24"
    zone = "KR-1"
    name = "public-subnet-1"
    network_acl_no = ncloud_vpc.vpc.default_network_acl_no
    subnet_type = "PUBLIC"
    usage_type = "GEN"
}

resource "ncloud_subnet" "public_subnet_2" {
    vpc_no = ncloud_vpc.vpc.id
    subnet = "10.0.4.0/24"
    zone = "KR-2"
    name = "public-subnet-2"
    network_acl_no = ncloud_vpc.vpc.default_network_acl_no
    subnet_type = "PUBLIC"
    usage_type = "GEN"
}
