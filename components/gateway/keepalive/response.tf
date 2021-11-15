resource "aws_apigatewayv2_integration_response" "ping" {
  api_id                   = var.api_id
  integration_id           = aws_apigatewayv2_integration.ping.id
  integration_response_key = "/200/" # must be /XXX/ or $default

  template_selection_expression = "200"
  response_templates            = {
    "200" = file("${path.module}/pong.json")
  }
}

resource "aws_apigatewayv2_route_response" "ping" {
  api_id             = var.api_id
  route_id           = aws_apigatewayv2_route.ping.id
  route_response_key = "$default" # must be default
}
