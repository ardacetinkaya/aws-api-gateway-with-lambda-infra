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
    max_vcpus = 8

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

resource "aws_batch_job_definition" "job_definition_01" {
  name = "job_definition_01"
  type = "container"
  platform_capabilities = [
    "FARGATE"
  ]
  
  

  container_properties = jsonencode({
        image   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/testartifacts:scheduled-v1-latest"
        fargatePlatformConfiguration = {
          platformVersion = "LATEST"
        },
        resourceRequirements = [
          { type = "VCPU", value = "0.5" },
          { type = "MEMORY", value = "1024" }
        ],
        executionRoleArn = aws_iam_role.task_execution_role.arn
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.job_definition_01_log_group_01.id
            awslogs-region        = var.region
            awslogs-stream-prefix = "batch"
          }
        }
        networkConfiguration={
          assignPublicIp = "ENABLED"
        }
      })
}

resource "aws_iam_role" "task_execution_role" {
  name               = "task-exec"
  assume_role_policy = data.aws_iam_policy_document.task_execution_role.json
}

data "aws_iam_policy_document" "task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_batch_job_queue" "job_queue_01" {
  name     = "batch-job-queue"
  state    = "ENABLED"
  priority = 1

  compute_environments = [
    aws_batch_compute_environment.some_batch_compute_01.arn
  ]
}

resource "aws_cloudwatch_log_group" "job_definition_01_log_group_01" {
  name              = "/aws/batch/job_definition_01"
  retention_in_days = 1
}
