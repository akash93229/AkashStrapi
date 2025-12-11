
# ------------------------------
# KEY PAIR
# ------------------------------
resource "aws_key_pair" "strapi_key" {
  key_name   = "strapi-key"
  public_key = file("/home/ubuntu/.ssh/id_rsa.pub")
}
# ------------------------------
# SECURITY GROUPS
# ------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "strapi-ec2-sg"
  description = "Allow 22, 80, 1337"
  vpc_id      = aws_vpc.main.id # vpc.tf defines aws_vpc.main

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "strapi-ec2-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "strapi-rds-sg"
  description = "Managed by Terraform"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-rds-sg"
  }
}

# ------------------------------
# RDS SUBNET GROUP
# ------------------------------
resource "aws_db_subnet_group" "db_subnets" {
  name       = "strapi-db-subnets"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id] # vpc.tf defines private_subnets
  tags = {
    Name = "db-subnet-group"
  }
}


# RDS INSTANCE
resource "aws_db_instance" "strapi_db" {
  identifier             = "strapi-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "strapi"
  password               = "Strapi1234"
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}
# ------------------------------
# EC2 INSTANCE
# ------------------------------
resource "aws_instance" "strapi_ec2" {
  ami                         = "ami-0dee22c13ea7a9a67"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id # vpc.tf defines public_subnet
  key_name                    = aws_key_pair.strapi_key.key_name
  vpc_security_group_ids       = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Strapi-EC2"
  }
}
