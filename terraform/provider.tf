# provider.tf
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = var.s3_bucket_name
    key            = "terraform.tfstate"
    region         = var.region
    dynamodb_table = var.dynamodb_table
  }
}

provider "aws" {
  region = var.region
}
