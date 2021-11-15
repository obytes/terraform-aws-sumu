module "connect" {
  source                = "./connect"
  api_id                = aws_apigatewayv2_api._.id
  credentials_arn       = aws_iam_role._.arn
  request_authorizer_id = aws_apigatewayv2_authorizer.request.id
}

module "disconnect" {
  source          = "./disconnect"
  api_id          = aws_apigatewayv2_api._.id
  credentials_arn = aws_iam_role._.arn
}

module "keepalive" {
  source          = "./keepalive"
  api_id          = aws_apigatewayv2_api._.id
  credentials_arn = aws_iam_role._.arn
}

module "publish" {
  source             = "./publish"
  api_id             = aws_apigatewayv2_api._.id
  credentials_arn    = aws_iam_role._.arn
  messages_topic_arn = var.messages_topic.arn
}

module "send" {
  source             = "./send"
  api_id             = aws_apigatewayv2_api._.id
  credentials_arn    = aws_iam_role._.arn
  messages_queue_url = var.messages_queue.url
}
