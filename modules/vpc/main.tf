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

