# IAM Role for Snowflake to access API Gateway
resource "aws_iam_role" "snowflake_role" {
  name = "snowflake_api_gateway_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::########"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "#########"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "snowflake_api_policy" {
  name        = "snowflake_api_gateway_policy"
  description = "Policy to allow Snowflake to invoke API Gateway"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "execute-api:Invoke",
        Effect   = "Allow",
        Resource = "${aws_api_gateway_rest_api.openweather_api.execution_arn}/*/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_policy_attach" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.snowflake_api_policy.arn
}
