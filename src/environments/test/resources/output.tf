output "function_name" {
  description = "Lambda function name"
  value = aws_lambda_function.hello_lambda.function_name
}

output "function_url" {
  value = aws_lambda_function_url.hello_lambda_url.function_url
}