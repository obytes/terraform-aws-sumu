resource "aws_apigatewayv2_integration_response" "hello" {
  api_id                   = var.api_id
  integration_id           = aws_apigatewayv2_integration.ack_presence.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "hello" {
  api_id             = var.api_id
  route_id           = aws_apigatewayv2_route.connect.id
  route_response_key = "$default"
}
