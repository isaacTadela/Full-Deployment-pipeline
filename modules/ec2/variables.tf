variable "master_public_ip" {}

variable "master_private_ip" {}

variable "vault_token" {}

variable "region" {}

variable "environment" {}

variable "ami" {}

variable "instance_type" {}

variable "autoscaling_group_min_size" {}

variable "autoscaling_group_max_size" {}

variable "autoscaling_group_desired_capacity" {}

variable "vpc_id" {}

variable "public_subnets" {}

variable "target_group_arn" {}

variable "alb_arn_suffix" {}

variable "db_hostname" {}

variable "db_port" {}

variable "db_username" {}

variable "db_password" {}

variable "autoscaling_tags" {}
