output "environment" {
  value = var.environment
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "private_subnets" {
  value = [ aws_subnet.private.*.id ]
}

output "cidr_block_private" {
  value = [ aws_subnet.private.*.cidr_block ]
}

output "public_subnets" {
  value = [ aws_subnet.public.*.id ]
}

output "cidr_block_public" {
  value = [ aws_subnet.public.*.cidr_block ]
}