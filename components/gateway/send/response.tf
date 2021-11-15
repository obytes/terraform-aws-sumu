resource "aws_apigatewayv2_integration_response" "send" {
  api_id                   = var.api_id
  integration_id           = aws_apigatewayv2_integration.send.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "send" {
  api_id             = var.api_id
  route_id           = aws_apigatewayv2_route.send.id
  route_response_key = "$default"
}
