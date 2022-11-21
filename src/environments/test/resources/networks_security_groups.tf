resource "aws_security_group" "security_group_01" {
  name          = "WWW-Security Group"
  vpc_id        = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  provider = aws.primary-region
}

resource "aws_security_group" "security_group_02" {
  name          = "SSH-Security Group"
  vpc_id        = aws_vpc.main.id

	ingress {
		cidr_blocks = ["0.0.0.0/0"]
		from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

  provider = aws.primary-region
}