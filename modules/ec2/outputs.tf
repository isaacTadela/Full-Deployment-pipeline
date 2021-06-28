output "admin_key_name" {
  value = aws_key_pair.admin_key.key_name
}

output "launch_config_id" {
  value = aws_launch_configuration.launch_config.id
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.autoscaling_group.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}