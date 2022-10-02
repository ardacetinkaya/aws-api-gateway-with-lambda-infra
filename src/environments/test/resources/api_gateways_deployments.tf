resource "aws_api_gateway_deployment" "deployment_01" {
  rest_api_id = aws_api_gateway_rest_api.hello_lambda_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource_01.id,
      aws_api_gateway_method.method_00.id,
      aws_api_gateway_method.method_01.id,
      aws_api_gateway_integration.integration_00.id,
      aws_api_gateway_integration.integration_01.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
