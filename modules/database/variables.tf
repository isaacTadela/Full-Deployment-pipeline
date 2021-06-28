variable "azs" {}

variable "vpc_id" {}

variable "private_subnet" {}

variable "environment" {}

variable "port" {}

variable "username" {}

variable "password" {}

variable "name" {}

variable "multi_az" {
  default = false
}

variable "protocol" {
  default = "TCP"
}

variable "apply_immediately" {
  default = true
}

variable "publicly_accessible" {
  default = "true"
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  default = "5.7.26"
}

variable "instance_class" {
  default = "db.t2.micro"
}

variable "storage_type" {
  default = "standard"
}

variable "allocated_storage" {
  default = "20"
}

variable "skip_final_snapshot" {
  default = true
}