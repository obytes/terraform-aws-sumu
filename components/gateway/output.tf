output "ws_api_id" {
  value = aws_apigatewayv2_api._.id
}

output "ws_api_stage_name" {
  value = aws_apigatewayv2_stage._.name
}

output "agma_arn" {
  value = "${aws_apigatewayv2_api._.execution_arn}/${aws_apigatewayv2_stage._.name}/POST/@connections"
}

output "authorized_apis" {
  value = [
    "${aws_apigatewayv2_api._.execution_arn}/${aws_apigatewayv2_stage._.name}/*"
  ]
}
