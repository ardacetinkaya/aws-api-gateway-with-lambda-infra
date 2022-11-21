resource "aws_subnet" "subnet_01" {
  vpc_id                        = aws_vpc.main.id
  cidr_block                    = "10.0.1.0/24"
  map_public_ip_on_launch       = true
  
  provider                      = aws.primary-region
  tags = {
    Name = "main_subnet_#01"
  }

}

resource "aws_subnet" "subnet_02" {
  vpc_id                        = aws_vpc.main.id
  cidr_block                    = "10.0.2.0/24"
  map_public_ip_on_launch       = true
  
  provider                      = aws.primary-region
  tags = {
    Name = "main_subnet_#02"
  }

}