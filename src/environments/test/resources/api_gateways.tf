
resource "aws_api_gateway_rest_api" "hello_lambda_api" {
  name              = "http-api-lambda"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_api_gateway_model" "response_model_01" {
  rest_api_id  = aws_api_gateway_rest_api.hello_lambda_api.id
  name         = "WeeklyForecast"
  description  = "A JSON schema for response"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "WeeklyForecastResponse",
  "type": "object",
  "properties": {
    "name": { "type": "string" },
    "requestTime": { "type": "string" },
    "weather": {
      "type": "array",
      "items": { "type": "string" }
    }
  }
}
EOF
}

resource "aws_api_gateway_model" "response_model_02" {
  rest_api_id  = aws_api_gateway_rest_api.hello_lambda_api.id
  name         = "Empty"
  description  = "A JSON schema for response"
  content_type = "application/json"

  schema = <<EOF
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title" : "Empty Schema",
  "type" : "object"
}
EOF
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda_v1.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.hello_lambda_api.execution_arn}/*/*/*"
}

data "aws_api_gateway_rest_api" "name" {
  name = aws_api_gateway_rest_api.hello_lambda_api.name
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id = aws_api_gateway_resource.resource_01.id
  http_method = aws_api_gateway_method.get_method_01.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "integration_01_response_01" {
  rest_api_id = aws_api_gateway_rest_api.hello_lambda_api.id
  resource_id = aws_api_gateway_resource.resource_01.id
  http_method = aws_api_gateway_method.get_method_01.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  
  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "name" : "Weekly Forecast - $context.stage",
  "requestTime: "$context.requestTime",
  "weather" : [
#foreach($elem in $inputRoot)
 $elem.summary 
#if($foreach.hasNext),#end
#end
]
}
EOF
  }
}

