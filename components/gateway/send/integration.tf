resource "aws_apigatewayv2_integration" "send" {
  api_id                 = var.api_id
  description            = "Send websocket message through SQS"

  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "1.0"

  # Upstream
  integration_type     = "AWS"
  integration_uri      = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:action/SendMessage"
  connection_type      = "INTERNET"
  credentials_arn      = var.credentials_arn
  integration_method   = "POST"
  timeout_milliseconds = 5000

  request_parameters = {
    "integration.request.querystring.QueueUrl" = "'${var.messages_queue_url}'"
    "integration.request.querystring.MessageBody"  = "route.request.body.message"
    # Sender ID Attribute
    "integration.request.querystring.MessageAttributes.1.Name"              = "'user_id'"
    "integration.request.querystring.MessageAttributes.1.Value.DataType"    = "'String'"
    "integration.request.querystring.MessageAttributes.1.Value.StringValue" = "context.authorizer.principalId"
    # Message Timestamp Attribute
    "integration.request.querystring.MessageAttributes.2.Name"              = "'timestamp'"
    "integration.request.querystring.MessageAttributes.2.Value.DataType"    = "'Number'"
    "integration.request.querystring.MessageAttributes.2.Value.StringValue" = "context.requestTimeEpoch"
    # Message Source Attribute
    "integration.request.querystring.MessageAttributes.3.Name"               = "'source'",
    "integration.request.querystring.MessageAttributes.3.Value.DataType"     = "'String'",
    "integration.request.querystring.MessageAttributes.3.Value.StringValue"  = "'apigw.route.send'",
  }

  lifecycle {
    ignore_changes = [
      passthrough_behavior
    ]
  }
}
