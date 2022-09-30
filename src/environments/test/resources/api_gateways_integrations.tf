resource "aws_api_gateway_integration" "integration_00" {
  rest_api_id             = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id             = aws_api_gateway_rest_api.hello_lambda_api.root_resource_id
  http_method             = aws_api_gateway_method.method_00.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_lambda_v2.invoke_arn
}

resource "aws_api_gateway_integration" "integration_01" {
  rest_api_id             = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id             = aws_api_gateway_resource.resource_01.id
  http_method             = aws_api_gateway_method.method_01.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_lambda_v2.invoke_arn
}