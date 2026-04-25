# AWS VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.project_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-internet_gateway"
  }
}
# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# public Subnet1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "owned"
    "kubernetes.io/role/elb" = "1"
  }
}


# public subnet2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet2"
    "kubernetes.io/cluster/${var.project_name}-eks" = "owned"
    "kubernetes.io/role/elb" = "1"
  }
}


# private Subnet1
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  cidr_block              = "10.0.3.0/24"

  tags = {
    Name = "${var.project_name}-private-subnet1"
  }
}


# private subnet2
resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  cidr_block              = "10.0.4.0/24"

  tags = {
    Name = "${var.project_name}-private-subnet2"
  }
}

# elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
}


# nat gateway1
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}


# public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

# Private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "${var.project_name}-private-route-table"
  }
}

# public route table association 1
resource "aws_route_table_association" "public_subnet1_assoc" {
  subnet_id = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

# public route table association 2
resource "aws_route_table_association" "public_subnet2_assoc" {
  subnet_id = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# private route table association 1
resource "aws_route_table_association" "private_subnet1_assoc" {
  subnet_id = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

# private route table association 2
resource "aws_route_table_association" "private_subnet2_assoc" {
  subnet_id = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}