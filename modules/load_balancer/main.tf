resource "aws_security_group" "alb" {
  name        			= "alb_security_group_name"
  vpc_id      			= var.vpc_id

  ingress {
    from_port   		= var.source_port
    to_port     		= var.source_port
    protocol    		= var.source_protocol
    cidr_blocks 		= ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   		= 0
    to_port     		= 0
    protocol    		= "-1"
    cidr_blocks 		= ["0.0.0.0/0"]
  }

  tags 					= { Name = "${var.environment}-alb-security-group" }
}


resource "aws_alb" "alb" {
  name            		= "alb"
  load_balancer_type 	= "application"
  security_groups 		= [aws_security_group.alb.id]
  subnets         		= var.public_subnets[0]
  
  tags 					= { Name = "${var.environment}-alb" }
}


resource "aws_alb_target_group" "group" {
  name     				= "alb-target"
  port     				= var.target_port
  protocol 				= var.target_protocol
  vpc_id   				= var.vpc_id
  stickiness {
    type = "lb_cookie"
  }
  
  #You can alter the destination of the health check, this will check the home page
  health_check {
    path 				= var.health_check_path
    port 				= var.target_port
  }
  
  tags 					= { Name = "${var.environment}-alb-target-group" }
}


resource "aws_alb_listener" "listener_http" {
  load_balancer_arn 	= aws_alb.alb.arn
  port              	= var.target_port
  protocol          	= var.target_protocol

  default_action {
    target_group_arn 	= aws_alb_target_group.group.arn
    type             	= "forward"
  }
}


