output "alb_security_group" {
  value = [ aws_security_group.alb.id ]
}

output "alb_id" {
  value = [ aws_alb.alb.id ]
}

output "alb_dns_name" {
  value = aws_alb.alb.dns_name 
}

output "target_group_arn" {
  value = aws_alb_target_group.group.arn
}

output "alb_arn_suffix" {
  value = aws_alb.alb.arn_suffix
}