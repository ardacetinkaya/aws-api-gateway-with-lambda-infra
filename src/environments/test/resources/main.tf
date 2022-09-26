provider "aws" {
  region = var.region
  alias = "primary-region"
}

terraform {  
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}