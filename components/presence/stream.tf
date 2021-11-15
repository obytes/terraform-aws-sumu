resource "aws_lambda_event_source_mapping" "presence_stream" {
  enabled                = true
  event_source_arn       = var.connections_table.stream_arn
  function_name          = aws_lambda_function.function.arn

  starting_position             = "LATEST"
  maximum_retry_attempts        = 5 # Retry for five times
  maximum_record_age_in_seconds = 60 # Ignore Offline/Online events older than 1minutes
}
