resource "aws_route_table" "route_table_01" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_01.id
  }

  provider = aws.primary-region
	tags = {
		Name = "route_tbl_#1"
	}
}

resource "aws_route_table_association" "route_table_association_01" {
  subnet_id      = aws_subnet.subnet_01.id
  route_table_id = aws_route_table.route_table_01.id

  provider = aws.primary-region
}
