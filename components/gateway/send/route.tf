resource "aws_apigatewayv2_route" "send" {
  api_id         = var.api_id

  # UPSTREAM
  target         = "integrations/${aws_apigatewayv2_integration.send.id}"
  route_key      = "send"
  operation_name = "Send websocket message through SQS"

  # AUTHORIZATION
  authorization_type = "NONE"
  api_key_required   = false

  route_response_selection_expression = "$default"
}
