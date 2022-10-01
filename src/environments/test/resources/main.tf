provider "aws" {
  region = var.region
  alias = "primary-region"
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