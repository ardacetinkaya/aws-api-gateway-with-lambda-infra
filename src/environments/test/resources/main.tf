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