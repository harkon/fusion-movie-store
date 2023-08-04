output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.api.stage_name}"
}

# output "api_gateway_url" {
#   value = aws_apigatewayv2_api.main.api_endpoint
# }