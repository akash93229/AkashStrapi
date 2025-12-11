# main.tf

########################
# VPC
########################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "strapi-vpc"
  }
}

########################
# Subnets
########################

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 10)
  availability_zone = "${var.region}${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

########################
# INTERNET GATEWAY
########################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "strapi-igw"
  }
}

########################
# PUBLIC ROUTE TABLE
########################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

########################
# SECURITY GROUPS
########################

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

########################
# EC2
########################

resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  user_data = file("userdata.sh")

  tags = {
    Name = "strapi-ec2"
  }
}

########################
# DB SUBNET GROUP
########################

resource "aws_db_subnet_group" "db_subnets" {
  name       = "strapi-db-subnets"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "strapi-db-subnet-group"
  }
}

########################
# RDS
########################

resource "aws_db_instance" "strapi_db" {
  identifier              = "strapi-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = 20
  publicly_accessible     = false
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "strapi-rds"
  }
}
