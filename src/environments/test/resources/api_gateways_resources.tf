resource "aws_api_gateway_resource" "resource_01" {
  rest_api_id = aws_api_gateway_rest_api.hello_lambda_api.id
  parent_id   = aws_api_gateway_rest_api.hello_lambda_api.root_resource_id
  path_part   = "{proxy+}"

  depends_on = [
    aws_api_gateway_rest_api.hello_lambda_api
  ]
}