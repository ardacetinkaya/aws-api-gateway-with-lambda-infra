locals {
	cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl" "acl_01" {
  vpc_id = aws_vpc.main.id
	subnet_ids = [
		"${aws_subnet.subnet_01.id}"
	]
  egress {
    protocol   = "tcp"
    rule_no    = 10
    action     = "allow"
    cidr_block = local.cidr_block 
    from_port  = 8080
    to_port    = 8080
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 10
    action     = "allow"
    cidr_block = local.cidr_block 
    from_port  = 8080
    to_port    = 8080
  }

	# allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.cidr_block 
    from_port  = 22
    to_port    = 22
  }
  
  # allow ingress port 80 
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = local.cidr_block 
    from_port  = 80
    to_port    = 80
  }
    
  # allow egress port 22 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = local.cidr_block
    from_port  = 22 
    to_port    = 22
  }
  
  # allow egress port 80 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = local.cidr_block
    from_port  = 80  
    to_port    = 80 
  }
 
	provider = aws.primary-region
	tags = {
			Name = "main"
	}
}