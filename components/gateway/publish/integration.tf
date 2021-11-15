resource "aws_apigatewayv2_integration" "publish" {
  api_id                 = var.api_id
  description            = "Publish websocket message through SNS"

  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "1.0"

  # Upstream
  integration_type     = "AWS"
  integration_uri      = "arn:aws:apigateway:${data.aws_region.current.name}:sns:action/Publish"
  connection_type      = "INTERNET"
  credentials_arn      = var.credentials_arn
  integration_method   = "POST"
  timeout_milliseconds = 5000

  request_parameters = {
    "integration.request.querystring.TopicArn" = "'${var.messages_topic_arn}'"
    "integration.request.querystring.Message"  = "route.request.body.message"
    # Sender ID Attribute
    "integration.request.querystring.MessageAttributes.entry.1.Name"              = "'user_id'",
    "integration.request.querystring.MessageAttributes.entry.1.Value.DataType"    = "'String'",
    "integration.request.querystring.MessageAttributes.entry.1.Value.StringValue" = "context.authorizer.principalId",
    # Message Timestamp Attribute
    "integration.request.querystring.MessageAttributes.entry.2.Name"              = "'timestamp'",
    "integration.request.querystring.MessageAttributes.entry.2.Value.DataType"    = "'Number'",
    "integration.request.querystring.MessageAttributes.entry.2.Value.StringValue" = "context.requestTimeEpoch",
    # Message Source Attribute
    "integration.request.querystring.MessageAttributes.entry.3.Name"              = "'source'",
    "integration.request.querystring.MessageAttributes.entry.3.Value.DataType"    = "'String'",
    "integration.request.querystring.MessageAttributes.entry.3.Value.StringValue" = "'apigw.route.publish'",
  }

  lifecycle {
    ignore_changes = [
      passthrough_behavior
    ]
  }
}
