resource "aws_api_gateway_integration" "integration_01" {
  rest_api_id             = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id             = aws_api_gateway_resource.resource_01.id
  http_method             = aws_api_gateway_method.get_method_01.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "${data.aws_lambda_function_url.hello_lambda_v1_url.function_url}weatherforecast"
}

resource "aws_api_gateway_integration" "integration_02" {
  rest_api_id             = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id             = aws_api_gateway_resource.resource_01.id
  http_method             = aws_api_gateway_method.post_method_02.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_lambda_v1.invoke_arn
  
}