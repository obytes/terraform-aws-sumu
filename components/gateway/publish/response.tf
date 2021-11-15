resource "aws_apigatewayv2_integration_response" "publish" {
  api_id                   = var.api_id
  integration_id           = aws_apigatewayv2_integration.publish.id
  integration_response_key = "/200/"
}

resource "aws_apigatewayv2_route_response" "publish" {
  api_id             = var.api_id
  route_id           = aws_apigatewayv2_route.publish.id
  route_response_key = "$default"
}
