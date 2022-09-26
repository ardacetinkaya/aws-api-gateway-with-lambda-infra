resource "aws_api_gateway_deployment" "deployment_01" {
  rest_api_id = aws_api_gateway_rest_api.hello_lambda_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource_01.id,
      aws_api_gateway_method.get_method_01.id,
      aws_api_gateway_model.response_model_01.id,
      aws_api_gateway_method_response.response_200.id,
      aws_api_gateway_integration.integration_01.id,
      aws_api_gateway_integration_response.integration_01_response_01.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev_stage_01" {
  deployment_id = aws_api_gateway_deployment.deployment_01.id
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  stage_name    = "dev"
}