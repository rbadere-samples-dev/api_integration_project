# Outputs
/*
output "api_gateway_url" {
  value = "${aws_api_gateway_stage.prod.invoke_url}/weather"
}*/

output "snowflake_role_arn" {
  value = aws_iam_role.snowflake_role.arn
}

output "cloudwatch_role_arn" {
  value = aws_iam_role.apigateway_cloudwatch_logs.arn
}