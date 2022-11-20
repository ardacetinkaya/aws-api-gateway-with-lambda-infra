provider "aws" {
  region = var.region
  alias = "primary-region"

  default_tags {
    tags = {
        Environment = "Test"
        Project     = "Self-Learn"
    }
  }
}

terraform {  
    backend "s3" { }
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "main_network_01" {
  filter {
    name   = "tag:Name"
    values = ["main_network"]
  }
}

data "aws_subnet" "main_network_01_subnet_01" {
  filter {
    name   = "tag:Name"
    values = ["main_subnet_#01"]
  }
}