locals {
  job_definitioin_name = "job_definition_01"
  job_queue_name = "batch-job-queue-01"
}
resource "aws_batch_job_definition" "job_definition_01" {
  name = local.job_definitioin_name
  type = "container"
  platform_capabilities = [
    "FARGATE"
  ]

  container_properties = jsonencode({
    image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/testartifacts:scheduled-v1-latest"
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
    networkConfiguration = {
      assignPublicIp = "ENABLED"
    }
  })
}

resource "aws_cloudwatch_log_group" "job_definition_01_log_group_01" {
  name              = "/aws/batch/${local.job_definitioin_name}"
  retention_in_days = 1
}


resource "aws_iam_role" "task_execution_role" {
  name               = "task-exec"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_policy.json
}

data "aws_iam_policy_document" "assume_role_policy_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "batch_policy_01" {
  name = "batch-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "batch01",
        "Effect" : "Allow",
        "Action" : "batch:SubmitJob",
        "Resource" : [
          "arn:aws:batch:${var.region}:${data.aws_caller_identity.current.account_id}:job-definition/${local.job_definitioin_name}",
          "arn:aws:batch:${var.region}:${data.aws_caller_identity.current.account_id}:job-definition/${local.job_definitioin_name}:*",
          "arn:aws:batch:${var.region}:${data.aws_caller_identity.current.account_id}:job-queue/${local.job_queue_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "batch_policy_01" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.batch_policy_01.arn
}
