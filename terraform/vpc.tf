# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "strapi-vpc"
  }
}

# -------------------------------
# Public Subnet (for EC2)
# -------------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"

  tags = {
    Name = "public-subnet"
  }
}

# -------------------------------
# Private Subnets (for RDS)
# -------------------------------
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "private-subnet-2"
  }
}

# -------------------------------
# Internet Gateway (EC2 needs internet)
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# -------------------------------
# Public Route Table
# -------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------
# RDS Subnet Group (mandatory)
# -------------------------------
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "strapi-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]

  tags = {
    Name = "db-subnet-group"
  }
}
