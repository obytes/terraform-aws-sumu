resource "aws_apigatewayv2_route" "disconnect" {
  api_id         = var.api_id

  # UPSTREAM
  target         = "integrations/${aws_apigatewayv2_integration.ack_absence.id}"
  route_key      = "$disconnect"
  operation_name = "Acknowledge user absence"

  # AUTHORIZATION
  authorization_type = "NONE"
  api_key_required   = false

  route_response_selection_expression = "$default"
}
