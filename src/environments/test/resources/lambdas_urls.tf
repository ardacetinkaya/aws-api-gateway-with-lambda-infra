
resource "aws_lambda_function_url" "hello_lambda_v1_url" {
  function_name      = aws_lambda_function.hello_lambda_v1.function_name
  authorization_type = "NONE"

  depends_on = [
    aws_lambda_function.hello_lambda_v1
  ]
}

resource "aws_lambda_function_url" "hello_lambda_v2_url" {
  function_name      = aws_lambda_function.hello_lambda_v2.function_name
  authorization_type = "NONE"

  depends_on = [
    aws_lambda_function.hello_lambda_v2
  ]
}

resource "aws_lambda_function_url" "hello_lambda_v3_url" {
  function_name      = aws_lambda_function.hello_lambda_v3.function_name
  authorization_type = "NONE"

  depends_on = [
    aws_lambda_function.hello_lambda_v3
  ]
}


data "aws_lambda_function_url" "hello_lambda_v1_url" {
  function_name     = local.lambda.function_v1_name

  depends_on = [
    aws_lambda_function.hello_lambda_v1,
    aws_lambda_function_url.hello_lambda_v1_url
  ]
}

data "aws_lambda_function_url" "hello_lambda_v2_url" {
  function_name     = local.lambda.function_v2_name

  depends_on = [
    aws_lambda_function.hello_lambda_v2,
    aws_lambda_function_url.hello_lambda_v2_url
  ]
}
