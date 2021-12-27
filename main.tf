# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY MY APPLICATION IN AWS
# These templates show an example of how to deploy an application in AWS. 
# We deploy a VPC, RDS, ASG and more.
# Each step is complateded before the next one begin, this is not a must.
# Note that these templates assume that you have an HashiCorp Vault unseald, AWS Access key ID 
# and secret access key are configured as environment variables and as Terraform environment variables 
# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------
# REMOTE STATEFILE S3 BACKEND 
# ----------------------------------------------------------------------------------------------------------------------
terraform {
   backend "s3" {
    bucket 						= "workshop-tf-state-isaac"
    encrypt 					= true
    key 							= "workshop-site-state-isaac/terraform.tfstate"
    dynamodb_table 		= "tf-workshop-site-locks"
    region 						= "eu-west-3"
  }
} 

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC VAULT VERSION OR HIGHER - 2.24.X
# ----------------------------------------------------------------------------------------------------------------------
provider "vault" {
  # This default use $VAULT_ADDR But can be set explicitly
  # address = "https://vault.example.net:8200"
  # I use $TF_VAR_VAULT_ADDR just for the practice of terraform environment variables 
  address = var.VAULT_ADDR
  token   = var.VAULT_TOKEN

  # This version in here only because of a bug in version 3.0.0
  # The open issue: https://github.com/hashicorp/terraform-provider-vault/issues/1226
  # The issue is: policy_arns cannot be null on version 3.0.0
  version = "~> 2.24.1"
}


# ---------------------------------------------------------------------------------------------------------------------
# ENABLE AWS SECRET ENGINE IN VAULT 
# This will use the access and secret keys from the main's variables file in order to enable the aws secret engine in
# the vault server and create a vault policy and role to be use in the next steps
# Vault will generate a temporary leased aws tokens for terraform to provision the resources and for the EC2 machines 
# ---------------------------------------------------------------------------------------------------------------------
module "vault" {
  source = "./modules/vault"
  
  AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
  region                = var.region
}


# ---------------------------------------------------------------------------------------------------------------------
# SET THE CLOUD PROVIDER
# A temporary vault generated iam user that have the permission policy 'ec2-node-role' will provision 
# all the resource here in aws 

# terraform = vault-token-terraform-ec2-node-role-1640474340-3330
# ec2       = vault-root-ec2-node-role-1640475142-3490
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  access_key  = module.vault.access_key
  secret_key  = module.vault.secret_key
  region      = var.region
  

  default_tags {
    tags      = var.default_tags
  }

  depends_on  = [module.vault]
}


# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY a Virtual Private Cloud (VPC) 
# Here we deploy most of out network layer, we will have an address range of 16382 in 4 subnets witch divided equally  
# into two public subnets and two private subnets. The main purpose of the private subnets is to protect the DB from
# any connect other then the public subnets

# FireWall
# Network ACL define which traffic can enter a subnet

# Routing 
# route table - controll routing of outgoing network requests, block / allow


# Combine route table with eip and you get 'public' and private subnets

# eip - Elastic IP addresses
# internet gateway - 
# nat gateway ( 'private internet gateway' ) - traslate private ips to a public and fowerd to the internet gateway, 
#               reside in the public subnet and pointed by the route table from the private subnet


# ---------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"
  
  azs 								  = var.azs
  vpc_cidr 						  = var.vpc_cidr
  private_subnets 		  = var.private_subnets
  public_subnets 			  = var.public_subnets
  environment 				  = var.environment

  depends_on            = [provider.aws]
}


# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN Relational Database Service (RDS)
# For an isolated environment we will deploy an t2.micro instance in our private subnets. All the setting of the 
# DB can be found in the variables file and you can change them to suit your needs.
# ---------------------------------------------------------------------------------------------------------------------
module "database" {
  source = "./modules/database"
  
  azs 							 		= var.azs
  private_subnet 				= module.vpc.private_subnets[0]
  vpc_id 								= module.vpc.vpc_id
  environment 					= var.environment
  password 							= var.db_password
  username 							= var.db_username
  port 								  = var.db_port
  name 								  = var.db_name
  
  depends_on            = [module.vpc]
}


# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN Application Load Balancer (ALB)
# It will be in one of the public subnets, with its own security group and forward only traffic on port 80 to the 
# target group and will perform health checks.
# ---------------------------------------------------------------------------------------------------------------------
module "alb" {
  source = "./modules/load_balancer"
  
  public_subnets 				= module.vpc.public_subnets
  vpc_id 								= module.vpc.vpc_id
  environment 					= var.environment
  
  depends_on            = [module.database]
}
  

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN Auto Scaling Group (ASG)
# Here we have most of the compute part, we can auto scale up and down according to out setup of Cloud Watch matrices
# Note This resource also have a security group but with *hard coded* ports for SSH, HTTP and Grafana for now.
# Each of instace will have a key for ssh connection and a user-data script that will run at boot time 
# with environment variables for DB, Vault connections
# ---------------------------------------------------------------------------------------------------------------------
module "ec2" {
  source = "./modules/ec2"
  
  public_subnets 						          = module.vpc.public_subnets
  vpc_id 								              = module.vpc.vpc_id
  db_hostname							            = module.database.rds_hostname
  db_port 								            = module.database.rds_port
  db_username 							          = module.database.rds_username
  db_password 							          = module.database.rds_password
  target_group_arn 						        = module.alb.target_group_arn
  alb_arn_suffix                      = module.alb.alb_arn_suffix
  autoscaling_group_min_size 			    = var.autoscaling_group_min_size
  autoscaling_group_max_size 			    = var.autoscaling_group_max_size
  autoscaling_group_desired_capacity 	= var.autoscaling_group_desired_capacity
  instance_type 						          = var.instance_type
  ami 									              = var.ami
  environment 							          = var.environment
  autoscaling_tags                    = var.default_tags
  master_public_ip 									  = var.MASTER_PUBLIC_IP 
  master_private_ip 									= var.MASTER_PRIVATE_IP 
  vault_token                         = var.VAULT_TOKEN
  region                              = var.region

  depends_on                          = [module.alb]
} 
