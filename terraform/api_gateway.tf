# API Gateway (REST API)
resource "aws_api_gateway_rest_api" "openweather_api" {
  name        = "openweather_api"
  description = "REST API Gateway for OpenWeather Lambda"
}

# Define the /weather resource
resource "aws_api_gateway_resource" "weather" {
  rest_api_id = aws_api_gateway_rest_api.openweather_api.id
  parent_id   = aws_api_gateway_rest_api.openweather_api.root_resource_id
  path_part   = "weather"
}

# GET Method - Supports Query Parameters
resource "aws_api_gateway_method" "weather_get" {
  rest_api_id   = aws_api_gateway_rest_api.openweather_api.id
  resource_id   = aws_api_gateway_resource.weather.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.querystring.city" = true
  }
}

resource "aws_api_gateway_integration" "weather_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.openweather_api.id
  resource_id             = aws_api_gateway_resource.weather.id
  http_method             = aws_api_gateway_method.weather_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.openweather_lambda.invoke_arn
}

# POST Method - Supports Request Body
resource "aws_api_gateway_method" "weather_post" {
  rest_api_id   = aws_api_gateway_rest_api.openweather_api.id
  resource_id   = aws_api_gateway_resource.weather.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "weather_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.openweather_api.id
  resource_id             = aws_api_gateway_resource.weather.id
  http_method             = aws_api_gateway_method.weather_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.openweather_lambda.invoke_arn
}

# Method Responses for both GET & POST
resource "aws_api_gateway_method_response" "weather_response_get" {
  rest_api_id = aws_api_gateway_rest_api.openweather_api.id
  resource_id = aws_api_gateway_resource.weather.id
  http_method = aws_api_gateway_method.weather_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_method_response" "weather_response_post" {
  rest_api_id = aws_api_gateway_rest_api.openweather_api.id
  resource_id = aws_api_gateway_resource.weather.id
  http_method = aws_api_gateway_method.weather_post.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

# API Gateway Deployment & Stage
resource "aws_api_gateway_deployment" "weather_deployment" {
  depends_on = [
    aws_api_gateway_integration.weather_get_integration,
    aws_api_gateway_integration.weather_post_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.openweather_api.id
}

resource "aws_api_gateway_stage" "weather_stage" {
  deployment_id = aws_api_gateway_deployment.weather_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.openweather_api.id
  stage_name    = "prod"
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "apigw_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.openweather_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.openweather_api.execution_arn}/*/*"
}

# Output API Gateway URL
output "api_gateway_url" {
  value = "${aws_api_gateway_stage.weather_stage.invoke_url}/weather"
}
