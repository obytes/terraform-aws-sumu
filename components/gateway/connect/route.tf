resource "aws_apigatewayv2_route" "connect" {
  api_id         = var.api_id

  # UPSTREAM
  target         = "integrations/${aws_apigatewayv2_integration.ack_presence.id}"
  route_key      = "$connect"
  operation_name = "Acknowledge user presence"

  # AUTHORIZATION
  authorizer_id      = var.request_authorizer_id
  authorization_type = "CUSTOM"
  api_key_required   = false

  route_response_selection_expression = "$default"
}
