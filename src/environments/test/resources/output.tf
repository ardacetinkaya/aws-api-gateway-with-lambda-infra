output "function_name" {
  description = "Lambda function name"
  value = aws_lambda_function.hello_lambda_v1.function_name
}

output "function_url" {
  value = aws_lambda_function_url.hello_lambda_v1_url.function_url
}

output "hello_world_topic_01_arn" {
  value = aws_sns_topic.hello_world_topic_01.arn
}