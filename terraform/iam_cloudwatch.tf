resource "aws_iam_role" "apigateway_cloudwatch_logs" {
  name = "APIGatewayCloudWatchLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "apigateway_cloudwatch_logs_attach" {
  name       = "APIGatewayCloudWatchLogsAttachment"
  roles      = [aws_iam_role.apigateway_cloudwatch_logs.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "api_gateway_logging" {
  cloudwatch_role_arn = aws_iam_role.apigateway_cloudwatch_logs.arn
}
