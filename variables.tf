variable "environment" {
  description 	= "This is mainly used to set various ideintifiers and prefixes/suffixes"
  default     	= "production"
}

variable "region" {
  type        	= string
  default     	= "eu-west-3"
}

variable "azs" { 
  description 	= "Availability zones for VPC"
  default     	= ["eu-west-3a", "eu-west-3b", "eu-west-3b"]
}

variable "vpc_cidr" {
  type        	=  string
  description 	= "IP prefix of main vpc"
  default     	= "172.0.0.0/18"
}

variable "private_subnets" {
  description 	= "IP prefix of private subnets"
  default     	= ["172.0.0.0/20", "172.0.16.0/20"]
}

variable "public_subnets" {
  description 	= "IP prefix of public subnets"
  default     	= ["172.0.32.0/20", "172.0.48.0/20"]
}

variable "db_name" {
  default		= "rds_db"
}

variable "db_port" {
  default		= 3306
}

variable "db_username" {
  default		= "username"
}

variable "db_password" {
  default		= "password"
}

variable "autoscaling_group_min_size" {
  default		= 1
}

variable "autoscaling_group_max_size" {
  default		= 10
}

variable "autoscaling_group_desired_capacity" {
  default		= 1
}

variable "instance_type" {
  default		= "t2.micro"
}

variable "ami" {
  description 	= "Ubuntu Server 18.04"
  default		= "ami-0a0d71ff90f62f72a"
}
