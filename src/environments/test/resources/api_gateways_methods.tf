resource "aws_api_gateway_method" "get_method_01" {
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id   = aws_api_gateway_resource.resource_01.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_models = {
    "application/json" = "${aws_api_gateway_model.response_model_01.name}"
  }
}

resource "aws_api_gateway_method" "post_method_02" {
  rest_api_id   = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id   = aws_api_gateway_resource.resource_01.id
  http_method   = "POST"
  authorization = "NONE"
  
  request_models = {
    "application/json" = "${aws_api_gateway_model.response_model_01.name}"
  }
}