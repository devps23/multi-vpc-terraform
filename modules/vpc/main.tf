// create a vpc
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

# peer connection between vpc's
resource "aws_vpc_peering_connection" "peerconn" {
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.vpc.id
  auto_accept   = true
  tags = {
    Name = "${var.env}-vpcpeer"
  }
}
# create a frontend subnets
resource "aws_subnet" "frontend_subnets" {
  count     = length(var.frontend_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.frontend_subnets[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-frontend-subnet-${count.index+1}"
  }
}
# create a backend subnets
resource "aws_subnet" "backend_subnets" {
  count     = length(var.backend_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.backend_subnets[count.index]
  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = "${var.env}-backend-subnet-${count.index+1}"
  }
}
# create a backend subnets
resource "aws_subnet" "mysql_subnets" {
  count     = length(var.mysql_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.mysql_subnets[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-mysql-subnet-${count.index+1}"
  }
}
# create public subnets
resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-public-subnet-${count.index+1}"
  }
}

# create route table for frontend
resource "aws_route_table" "frontend" {
  count = length(var.frontend_subnets)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-frontend-rt-${count.index}"
  }
}
resource "aws_route_table" "backend" {
  count = length(var.backend_subnets)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-backend-rt-${count.index}"
  }
}
resource "aws_route_table" "mysql" {
  count = length(var.mysql_subnets)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-mysql-rt-${count.index}"
  }
}
resource "aws_route_table" "public" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-public-rt-${count.index}"
  }
}
# create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_route" "public" {
  count                     = length(var.public_subnets)
  route_table_id            = aws_route_table.public[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  vpc_peering_connection_id = aws_vpc_peering_connection.peerconn.id
  gateway_id                = aws_internet_gateway.gw.id
}
# create nat gateway
# resource "aws_nat_gateway" "nat" {
#   count = length(var.public_subnets)
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.public_subnets[count.index].id
#   tags = {
#     Name = "${var.env}-nat"
#   }
# }
# # create eip
#   resource "aws_eip" "eip" {
#     count    = length(var.public_subnets)
#     domain   = "${var.env}-eip"
#   }
#
# resource "aws_route" "frontend" {
#   count                     = length(var.frontend_subnets)
#   route_table_id            = aws_route_table.frontend[count.index].id
#   destination_cidr_block    = "0.0.0.0/0"
#   vpc_peering_connection_id = aws_vpc_peering_connection.peerconn.id
# }
# resource "aws_route" "backend" {
#   count                     = length(var.backend_subnets)
#   route_table_id            = aws_route_table.backend[count.index].id
#   destination_cidr_block    = "0.0.0.0/0"
#   vpc_peering_connection_id = aws_vpc_peering_connection.peerconn.id
# }
# resource "aws_route" "mysql" {
#   count                     = length(var.mysql_subnets)
#   route_table_id            = aws_route_table.mysql[count.index].id
#   destination_cidr_block    = "0.0.0.0/0"
#   vpc_peering_connection_id = aws_vpc_peering_connection.peerconn.id
# }

