locals {
  lambda = {
    function_v1_name    = "HelloLambda_v1"
    function_v2_name    = "HelloLambda_v2"
    function_v3_name    = "HelloLambda_v3"
    function_v4_name    = "HelloLambda_v4"
    runtime             = "dotnet6"
    memory_size         = 128
    timeout             = 10
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
  managed_policy_arns = [
    aws_iam_policy.ecr_policy_00.arn,
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  ]

}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ecr_policy_00" {
  name = "ecr-policy-00"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ecr:*",
            "Resource": "*"
        }
      ]
  })
}

resource "aws_lambda_function" "hello_lambda_v1" {
  function_name       = local.lambda.function_v1_name
  filename            = "${path.module}/../../../functions/HelloLambda.v1/bin/Release/net6.0/HelloLambda.v1.zip"
  role                = aws_iam_role.iam_for_HelloLambda.arn
  handler             = local.lambda.function_v1_name
  runtime             = local.lambda.runtime

  memory_size         = local.lambda.memory_size
  timeout             = local.lambda.timeout

  source_code_hash    = filebase64sha256("${path.module}/../../../functions/HelloLambda.v1/bin/Release/net6.0/HelloLambda.v1.zip")
  package_type        = "Zip"

  environment {
    variables = {
      SomeEnvVariable="This is some ENV Value"
      ASPNETCORE_ENVIRONMENT="Development"
    }
  }

  provider = aws.primary-region
}

resource "aws_lambda_function" "hello_lambda_v2" {
  function_name       = local.lambda.function_v2_name
  role                = aws_iam_role.iam_for_HelloLambda.arn

  memory_size         = local.lambda.memory_size
  timeout             = local.lambda.timeout

  package_type        = "Image"
  image_uri           = "${aws_ecr_repository.test_repository.repository_url}:v2-latest"
  image_config {
    command = ["HelloLambda.v2::HelloLambda.v2.LambdaEntryPoint::FunctionHandlerAsync"]
  }

  environment {
    variables = {
      SomeEnvVariable="This is some ENV Value"
      ASPNETCORE_ENVIRONMENT="Development"
    }
  }

  provider = aws.primary-region
}

resource "aws_lambda_function" "hello_lambda_v3" {
  function_name       = local.lambda.function_v3_name
  role                = aws_iam_role.iam_for_HelloLambda.arn

  memory_size         = local.lambda.memory_size
  timeout             = local.lambda.timeout

  package_type        = "Image"
  image_uri           = "${aws_ecr_repository.test_repository.repository_url}:v3-latest"
  image_config {
    command = ["HelloLambda.v3::HelloLambda.v3.Functions::Get"]
  }

  environment {
    variables = {
      SomeEnvVariable="This is some ENV Value"
      ASPNETCORE_ENVIRONMENT="Development"
    }
  }

  provider = aws.primary-region
}

resource "aws_lambda_function" "hello_lambda_v4" {
  function_name       = local.lambda.function_v4_name
  role                = aws_iam_role.iam_for_HelloLambda.arn

  memory_size         = local.lambda.memory_size
  timeout             = local.lambda.timeout

  package_type        = "Image"
  image_uri           = "${aws_ecr_repository.test_repository.repository_url}:v4-latest"
  image_config {
    command = ["HelloLambda.v4::HelloLambda.v4.Function::FunctionHandler"]
  }

  environment {
    variables = {
      SomeEnvVariable="This is some ENV Value"
      ASPNETCORE_ENVIRONMENT="Development"
    }
  }

  provider = aws.primary-region
}

