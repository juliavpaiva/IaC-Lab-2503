variable "instance_type" {
  type = string
}

variable "public_subnet_count" {
  type = string
}

variable "private_subnet_count" {
  type = string
}

variable "web_public_server_count" {
  type = string
}

variable "web_private_server_count" {
  type = string
}

variable "web_private_server_volume_size" {
  type = string
}

variable "rds_instance_volume_size" {
  type = string
}

variable "amazon_linux_ami" {
  type = string
  default = "ami-00169914e6299b8e0"
}

variable "ubuntu_ami" {
  type = string
  default = "ami-06d94a781b544c133"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}