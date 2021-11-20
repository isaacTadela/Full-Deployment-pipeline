terraform {
   backend "s3" {
    bucket 							= "workshop-tf-state-isaac"
    encrypt 							= true
    key 							= "workshop-site-state-isaac/terraform.tfstate"
    dynamodb_table 						= "tf-workshop-site-locks"
    region 							= "eu-west-3"
  }
} 


provider "vault" {
  # This will default use $VAULT_ADDR But can be set explicitly
  # address = "https://vault.example.net:8200"
  # I use $TF_VAR_VAULT_ADDR just for the practice
  address = var.VAULT_ADDR
  token = var.VAULT_TOKEN

  # This version in here only because of a bug in version 3.0.0
  # The issue link: https://github.com/hashicorp/terraform-provider-vault/issues/1226
  # The issue is: policy_arns cannot be null on version 3.0.0
  version = "~> 2.24.1"
}


resource "vault_aws_secret_backend" "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = var.region

  # 10min
  default_lease_ttl_seconds = "600" 
}

resource "vault_aws_secret_backend_role" "dev-admin" {
  backend = "${vault_aws_secret_backend.aws.path}"
  name    = "dev-admin-role"
  credential_type = "iam_user"

policy_document= <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*", "ec2:*", "rds:*", "elasticloadbalancing:*", "autoscaling:*", "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "vault_aws_access_credentials" "creds" {
  backend = vault_aws_secret_backend.aws.path
  role    = vault_aws_secret_backend_role.dev-admin.name
}

provider "aws" {
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
  region  = var.region

  default_tags {
    tags = var.default_tags
  }
}


module "vpc" {
  source = "./modules/vpc"
  
  azs 								= var.azs
  vpc_cidr 							= var.vpc_cidr
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
  autoscaling_tags                      = var.default_tags
  master_ip 									= var.MASTER_IP 
  aws_access_key              = var.AWS_ACCESS_KEY_ID
  aws_secret_key              = var.AWS_SECRET_ACCESS_KEY
  region  = var.region

  depends_on = [module.alb]
} 
