resource "aws_api_gateway_stage" "stage_v1" {
  deployment_id = aws_api_gateway_deployment.deployment_01.id
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  stage_name    = "v1"
}

resource "aws_api_gateway_stage" "stage_v2" {
  deployment_id = aws_api_gateway_deployment.deployment_01.id
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  stage_name    = "v2"
}

resource "aws_api_gateway_stage" "stage_v3" {
  deployment_id = aws_api_gateway_deployment.deployment_01.id
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  stage_name    = "v3"
}