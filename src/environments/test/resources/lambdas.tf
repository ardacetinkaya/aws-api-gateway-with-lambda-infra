locals {
  lambda = {
    function_name   = "HelloLambda"
    runtime         = "dotnet6"
    memory_size     = 128
    timeout         = 10
  }
}

resource "aws_iam_role" "iam_for_HelloLambda" {
  name                = "iam_for_HelloLambda"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "hello_lambda" {
  function_name       = local.lambda.function_name
  filename            = "${path.module}/../../../artifacts/HelloLambda.zip"
  role                = aws_iam_role.iam_for_HelloLambda.arn
  handler             = local.lambda.function_name
  runtime             = local.lambda.runtime

  memory_size         = local.lambda.memory_size
  timeout             = local.lambda.timeout

  source_code_hash    = filebase64sha256("${path.module}/../../../artifacts/HelloLambda.zip")


  environment {
    variables = {
      test="test"
      ASPNETCORE_ENVIRONMENT="Development"
    }
  }

  provider = aws.primary-region
}

resource "aws_lambda_function_url" "hello_lambda_url" {
  function_name      = aws_lambda_function.hello_lambda.function_name
  authorization_type = "NONE"
}

data "aws_lambda_function_url" "hello_lambda_url" {
  function_name     = local.lambda.function_name
}
