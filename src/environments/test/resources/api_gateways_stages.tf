resource "aws_api_gateway_stage" "dev_stage_01" {
  deployment_id = aws_api_gateway_deployment.deployment_01.id
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  stage_name    = "dev"
}