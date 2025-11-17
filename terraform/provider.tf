terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"  # Update this line
    }
  }
}

provider "aws" {
  region = "us-east-1"
}