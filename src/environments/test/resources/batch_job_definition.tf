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

resource "aws_cloudwatch_log_group" "job_definition_01_log_group_01" {
  name              = "/aws/batch/job_definition_01"
  retention_in_days = 1
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

