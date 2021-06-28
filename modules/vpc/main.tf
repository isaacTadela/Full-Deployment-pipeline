resource "aws_vpc" "vpc" {
  cidr_block 				= var.vpc_cidr
  enable_dns_hostnames 		= var.enable_dns_hostnames
  enable_dns_support 		= var.enable_dns_support
  tags 						= { Name = "${var.environment}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id 					= aws_vpc.vpc.id
  cidr_block				= element(var.public_subnets, count.index)
  availability_zone 		= element(var.azs, count.index)
  count 					= length(compact(var.public_subnets))
  map_public_ip_on_launch 	= true
  tags 						= { Name = "${var.environment}-public_subnet" }
}

resource "aws_subnet" "private" {
  vpc_id 					= aws_vpc.vpc.id
  count 					= length(compact(var.private_subnets))
  cidr_block 				= element(var.private_subnets, count.index)
  availability_zone 		= element(var.azs, count.index)
  
  map_public_ip_on_launch 	= false
  tags 						= { Name = "${var.environment}-private_subnet" }
}

resource "aws_eip" "nat_eip" {
  vpc 						= true
  tags 						= { Name = "${var.environment}-eip" }
}

resource "aws_internet_gateway" "vpc" {
  vpc_id 					= aws_vpc.vpc.id
  tags 						= { Name = "${var.environment}-internet_gateway" }
}

resource "aws_nat_gateway" "gw" {
  allocation_id 			= aws_eip.nat_eip.id
  subnet_id 				= element(aws_subnet.public.*.id, 0)
  depends_on 				= [ aws_internet_gateway.vpc ]
  tags 						= { Name = "${var.environment}-eip" }
}

resource "aws_route_table" "public" {
  vpc_id 					= aws_vpc.vpc.id
  tags 						= { Name = "${var.environment}-route_table_public" }
}

resource "aws_route_table" "private" {
  vpc_id 					= aws_vpc.vpc.id
  tags 						= { Name = "${var.environment}-route_table_private" }
}

resource "aws_route_table_association" "private" {
  # Create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway
  count 					= length(compact(var.private_subnets))
  subnet_id 				= element(aws_subnet.private.*.id, count.index)
  route_table_id 			= aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  # Create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway
  count 					= length(compact(var.public_subnets))
  subnet_id 				= element(aws_subnet.public.*.id, count.index)
  route_table_id 			= aws_route_table.public.id
}

resource "aws_route" "nat_gateway" {
  # A resource to create a routing table entry (a route) in a VPC routing table
  route_table_id 			= aws_route_table.private.id
  destination_cidr_block 	= "0.0.0.0/0"
  nat_gateway_id 			= aws_nat_gateway.gw.id
}

resource "aws_route" "public_internet_gateway" {
  # A resource to create a routing table entry (a route) in a VPC routing table
  route_table_id 			= aws_route_table.public.id
  destination_cidr_block 	= "0.0.0.0/0"
  gateway_id	 			= aws_internet_gateway.vpc.id
}