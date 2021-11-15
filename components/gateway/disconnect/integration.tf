resource "aws_apigatewayv2_integration" "ack_absence" {
  api_id                 = var.api_id
  description            = "Acknowledge user absence"

  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "1.0"

  # Upstream
  integration_type     = "AWS"
  integration_uri      = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/DeleteItem"
  connection_type      = "INTERNET"
  credentials_arn      = var.credentials_arn
  integration_method   = "POST"
  timeout_milliseconds = 29000

  request_templates = {
    "application/json" = file("${path.module}/ddb_delete.json")
  }

  lifecycle {
    ignore_changes = [
      passthrough_behavior
    ]
  }
}