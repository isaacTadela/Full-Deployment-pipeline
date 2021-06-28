environment                      	= "production"

# Europe (Paris)
region 								= "eu-west-3"

azs 								= ["eu-west-3a", "eu-west-3b", "eu-west-3b"]

autoscaling_group_min_size 			= 2

autoscaling_group_max_size 			= 10

autoscaling_group_desired_capacity 	= 3

instance_type 						= "t2.micro"

# Ubuntu Server 18.04 LTS
ami 								= "ami-0a0d71ff90f62f72a"