resource "aws_batch_compute_environment" "some_batch_compute_01" {
  compute_environment_name = "some_batch_compute_01"

  compute_resources {
    max_vcpus = 8

    security_group_ids = [
      aws_security_group.some_batch_compute_01_sg_01.id
    ]

    subnets = [
      aws_subnet.subnet_01.id
    ]
    type = "FARGATE"
  }

  type         = "MANAGED"
  
  depends_on = [
    aws_security_group.some_batch_compute_01_sg_01
  ]
}

resource "aws_security_group" "some_batch_compute_01_sg_01" {
  name    = "some_batch_compute_01_sg_01"
  vpc_id  = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}