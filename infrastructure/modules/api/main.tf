resource "aws_api_gateway_rest_api" "API" {
  name        = "Serverless_Staic_Site"
  description = "Triggers lambda e-mail function"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  stage_name  = "production"
}

resource "aws_api_gateway_integration" "Integration" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  resource_id = aws_api_gateway_rest_api.API.root_resource_id
  http_method = aws_api_gateway_method.Method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  resource_id = aws_api_gateway_rest_api.API.root_resource_id
  http_method = aws_api_gateway_method.Method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
}

resource "aws_api_gateway_integration_response" "IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  resource_id = aws_api_gateway_rest_api.API.root_resource_id
  http_method = aws_api_gateway_method.Method.http_method
  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.API.id
  resource_id   = aws_api_gateway_rest_api.API.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_Integration" {
  rest_api_id             = aws_api_gateway_rest_api.API.id
  resource_id             = aws_api_gateway_rest_api.API.root_resource_id
  http_method             = aws_api_gateway_method.post.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = var.invoke_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "post_response_200" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  resource_id = aws_api_gateway_rest_api.API.root_resource_id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration_response" "post_IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  resource_id = aws_api_gateway_rest_api.API.root_resource_id
  http_method = aws_api_gateway_method.post.http_method
  status_code = aws_api_gateway_method_response.post_response_200.status_code
  response_templates = {
    "application/json" = ""
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.API.execution_arn}/*/POST/"
}

resource "aws_api_gateway_method" "Method" {
  rest_api_id   = aws_api_gateway_rest_api.API.id
  resource_id   = aws_api_gateway_rest_api.API.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}