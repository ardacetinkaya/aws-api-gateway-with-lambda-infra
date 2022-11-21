resource "aws_internet_gateway" "igw_01" {
  provider = aws.primary-region
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "test_internet_gateway"
  }
}