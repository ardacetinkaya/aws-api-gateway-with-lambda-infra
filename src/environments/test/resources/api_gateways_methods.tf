resource "aws_api_gateway_method" "method_00" {
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id   = aws_api_gateway_rest_api.hello_lambda_api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "method_01" {
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id   = aws_api_gateway_resource.resource_01.id
  http_method   = "GET"
  authorization = "NONE"
}