resource "aws_apigatewayv2_api" "_" {
  name          = "${local.prefix}-ws-api"
  description   = "Sosharu Websockets API"
  protocol_type = "WEBSOCKET"

  route_selection_expression   = "$request.body.action"
  api_key_selection_expression = "$request.header.x-api-key"

  tags = local.common_tags
}
