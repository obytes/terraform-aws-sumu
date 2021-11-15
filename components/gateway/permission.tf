resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = local.prefix
  action        = "lambda:InvokeFunction"
  function_name = var.request_authorizer.name
  qualifier     = var.request_authorizer.alias
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api._.execution_arn}/${aws_apigatewayv2_stage._.name}/*"
}
