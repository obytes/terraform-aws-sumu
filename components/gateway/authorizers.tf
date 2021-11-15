resource "aws_apigatewayv2_authorizer" "request" {
  name                       = "${var.prefix}-request-authz"
  api_id                     = aws_apigatewayv2_api._.id
  authorizer_type            = "REQUEST"
  identity_sources           = [
    "route.request.querystring.authorization",
    #"route.request.header.Authorization",
  ]
  authorizer_uri             = var.request_authorizer.invoke_arn
  authorizer_credentials_arn = aws_iam_role._.arn
}
