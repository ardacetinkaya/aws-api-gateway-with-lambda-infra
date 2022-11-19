data "aws_vpc" "main_network_01" {
  filter {
    name   = "tag:Name"
    values = ["main_network"]
  }
}

data "aws_subnet" "main_network_01_subnet_01" {
  filter {
    name   = "tag:Name"
    values = ["main_subnet_#01"]
  }
}


resource "aws_security_group" "some_batch_compute_01_sg_01" {
  name    = "some_batch_compute_01_sg_01"
  vpc_id  = data.aws_vpc.main_network_01.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_batch_compute_environment" "some_batch_compute_01" {
  compute_environment_name = "some_batch_compute_01"

  compute_resources {
    max_vcpus = 16

    security_group_ids = [
      aws_security_group.some_batch_compute_01_sg_01.id
    ]

    subnets = [
      data.aws_subnet.main_network_01_subnet_01.id
    ]

    type = "FARGATE"
  }

  type         = "MANAGED"
  depends_on = [
    aws_security_group.some_batch_compute_01_sg_01
  ]
}

resource "aws_batch_job_queue" "job_queue_01" {
  name     = "batch-job-queue"
  state    = "ENABLED"
  priority = 1

  compute_environments = [
    aws_batch_compute_environment.some_batch_compute_01.arn
  ]
}
