resource "aws_apigatewayv2_integration" "ping" {
  api_id                 = var.api_id
  description            = "Receive ping frame from client"

  # Upstream
  integration_type = "MOCK"

  template_selection_expression = "200"
  request_templates = {
    "200" = file("${path.module}/ping.json")
  }

  lifecycle {
    ignore_changes = [
      passthrough_behavior
    ]
  }
}
