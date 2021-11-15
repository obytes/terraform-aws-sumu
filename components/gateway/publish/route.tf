resource "aws_apigatewayv2_route" "publish" {
  api_id         = var.api_id

  # UPSTREAM
  target         = "integrations/${aws_apigatewayv2_integration.publish.id}"
  route_key      = "publish"
  operation_name = "Publish websocket message through SNS"

  # AUTHORIZATION
  authorization_type = "NONE"
  api_key_required   = false

  route_response_selection_expression = "$default"
}
