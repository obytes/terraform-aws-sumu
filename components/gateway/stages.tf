resource "aws_apigatewayv2_stage" "_" {
  name        = var.stage_name
  api_id      = aws_apigatewayv2_api._.id
  description = "Default Stage"
  auto_deploy = true

  access_log_settings {
    format          = jsonencode(local.access_logs_format)
    destination_arn = aws_cloudwatch_log_group.access.arn
  }

  default_route_settings {
    logging_level          = null
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }

  lifecycle {
    ignore_changes = [
      deployment_id,
    ]
  }
}
