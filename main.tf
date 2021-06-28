terraform {
   backend "s3" {
    bucket 								= "workshop-tf-state-isaac"
	encrypt 							= true
    key 								= "workshop-site-state-isaac/terraform.tfstate"
    dynamodb_table 						= "tf-workshop-site-locks"
    region 								= "eu-west-3"
  }
} 

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  
  azs 									= var.azs
  vpc_cidr 								= var.vpc_cidr
  private_subnets 						= var.private_subnets
  public_subnets 						= var.public_subnets
  environment 							= var.environment
}

module "database" {
  source = "./modules/database"
  
  azs 							 		= var.azs
  private_subnet 						= module.vpc.private_subnets[0]
  vpc_id 								= module.vpc.vpc_id
  environment 							= var.environment
  password 								= var.db_password
  username 								= var.db_username
  port 								    = var.db_port
  name 								    = var.db_name
  
  depends_on = [module.vpc]
}

module "alb" {
  source = "./modules/load_balancer"
  
  public_subnets 						= module.vpc.public_subnets
  vpc_id 								= module.vpc.vpc_id
  environment 							= var.environment
  
  depends_on = [module.database]
}
  
module "ec2" {
  source = "./modules/ec2"
  
  public_subnets 						= module.vpc.public_subnets
  vpc_id 								= module.vpc.vpc_id
  db_hostname							= module.database.rds_hostname
  db_port 								= module.database.rds_port
  db_username 							= module.database.rds_username
  db_password 							= module.database.rds_password
  target_group_arn 						= module.alb.target_group_arn
  alb_arn_suffix                        = module.alb.alb_arn_suffix
  autoscaling_group_min_size 			= var.autoscaling_group_min_size
  autoscaling_group_max_size 			= var.autoscaling_group_max_size
  autoscaling_group_desired_capacity 	= var.autoscaling_group_desired_capacity
  instance_type 						= var.instance_type
  ami 									= var.ami
  environment 							= var.environment
  
  
  depends_on = [module.alb]
} 