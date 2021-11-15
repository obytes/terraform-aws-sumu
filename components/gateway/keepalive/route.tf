resource "aws_apigatewayv2_route" "ping" {
  api_id         = var.api_id

  # UPSTREAM
  target         = "integrations/${aws_apigatewayv2_integration.ping.id}"
  route_key      = "ping"
  operation_name = "Ping websocket server"

  # AUTHORIZATION
  authorization_type = "NONE"
  api_key_required   = false

  route_response_selection_expression = "$default"
}
