# Terraform Infrastructure Provisioning
This repo creates environment modules with all the necessary resources to enable end-to-end interaction with a Web-app include VPC, RDS, Load-Balancer and EC2 on AWS


## What are we provisioning here?
- VPC and Gateway resources
- Security groups
- Subnets
- RDS
- Load-Balancer
- Autoscaling Group
- LaunchConfiguration (and a user-data script included)
- IAM Roles
- CloudWatch
    

## Prerequisite resources
- AWS cli configure with suitable privileges
- AWS S3 bucket holding the terraform statefile
- Dynamodb use for lock the statefile
- An admin RSA public key (so you could connect to the instances with SSH) 
- S3 Bucket with your artifacts, tar files of your web-application and a chef cookbooks (I used my cookboks you can find in [this repo](https://github.com/isaacTadela/Chef_ec2) )


## Persistence
- The terraform statefile is stored in an AWS S3 bucke
- The terraform lock file is stored in AWS Dynamodb


## Requirements

### Network Requirements:
- The inter-domain address range should be: 16382
- The address range should be equally distributed between the public-subnets and the private-subnets

### Instances Requirements:
- Use free-tier instances only (t2.micro)
- All resources will use public subnets to allow traffic from outside
- The instances should allow incoming traffic on port 80 from the LB only
- The instances should allow SSH access to the admin user

### RDS Requirements:
- Use free-tier instances only (t2.micro)
- All resources will use private subnets, to allow traffic only from the instances in the VPC
- [Required By AWS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html) ,Each DB subnet group must have at least one subnet in at least two Availability Zones in the AWS Region


## Setup and Adjustments

### Setup
You can basically run  ```terraform init```  to initialize the modules  
run  ```terraform plan```  for a dry-run  
and  ```terraform apply```  this will execute the code and setup the environment in the AWS region "eu-west-3" in about 10 minutes

### A little more advanced setup
Now suppose we want to provision the same environment for our development and testing teams in Europe but our customers are in the US  
So we can simply run the command  ```terraform apply -var-file=./prod/prod.tfvars```  and this will setup the exact same environment according to the variables in that file,  
for example setup the production environment in "us-east-1" region in the US for our customers
(another difference can be instances types or scale policy)

### EC2 Adjustments

#### Keys
Every instance needs a key and the public key here is the file '\modules\ec2\keysadmin.pub'  
and you can change it according to your generated key so you can ssh to the instances using you private key

#### Script
All instances runs the script at startup, you can find it in 'modules\ec2\templates\project-app.cloudinit',  
the script set system environment variable, installs chef-solo and awscli, afterwards download my cookbooks from my private S3 bucket,
and finally run my [Cookbooks](https://github.com/isaacTadela/Chef_ec2) 

#### EC2 Role - S3 Access
I assume that your application residing in an S3 bucket as a tar file  
So every ec2 instance have a role attached to allow it to access the S3, AmazonS3ReadOnlyAccess policy  
you can also customize to your needs


## Done
- Do not forget to initialize your database
- Do not forget to terminate the environment, 'time is money' so simply run ```terraform destroy``` after you done


## Diagram
Seeing is believing or understanding in our case so for the finally you can see here a 3D diagram of all the environment
(generated with [Cloudcraft](https://www.cloudcraft.co))

![cloudcraft diagram]( /cloudcraft%20diagram(3D).png )
