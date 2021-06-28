environment 						= "production"

# US East (N. Virginia)
region 								= "us-east-1"

azs 								= ["us-east-1a", "us-east-1b", "us-east-1c"]

autoscaling_group_min_size 			= 2

autoscaling_group_max_size 			= 10

autoscaling_group_desired_capacity 	= 3

instance_type 						= "t2.micro"

# Ubuntu Server 18.04 LTS
ami 								= "ami-042e8287309f5df03"