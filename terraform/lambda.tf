# Lambda Function
resource "aws_lambda_function" "openweather_lambda" {
  function_name = "openweather_lambda"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      OPENWEATHER_API_KEY = var.openweather_api_key
    }
  }
}