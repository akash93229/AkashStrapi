output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet for EC2 instance"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_ids" {
  description = "Private subnets for RDS"
  value       = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]
}

output "db_subnet_group_name" {
  description = "Subnet group used by RDS"
  value       = aws_db_subnet_group.db_subnet_group.name
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.strapi_ec2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint of RDS PostgreSQL"
  value       = aws_db_instance.strapi_db.endpoint
}
