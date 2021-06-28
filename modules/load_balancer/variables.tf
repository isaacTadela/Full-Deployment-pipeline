variable "vpc_id" {}

variable "public_subnets" {}

variable "environment" {}

variable "target_port" {
  default = "80"
}

variable "target_protocol" {
  default = "HTTP"
}

variable "source_port" {
  default = "80"
}

variable "source_protocol" {
  default = "TCP"
}

variable "health_check_path" {
  default = "/"
}

variable "multi_az" {
  default = false
}