locals {
  cidr_blocks = [
    "10.0.0.0/16"
  ]
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  provider = aws.primary-region
  tags = {
    Name = "main_network"
  }

}
