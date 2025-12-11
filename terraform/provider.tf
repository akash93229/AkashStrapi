terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-strapi-terraform-state"     # HARD CODE
    key            = "terraform.tfstate"
    region         = "ap-south-1"                    # HARD CODE
    dynamodb_table = "terraform-state-lock"          # HARD CODE
  }
}

provider "aws" {
  region = var.region
}
