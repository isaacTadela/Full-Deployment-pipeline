variable "vpc_cidr" {}

variable "azs" {}

variable "private_subnets" {}

variable "public_subnets" {}

variable "environment" {}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}