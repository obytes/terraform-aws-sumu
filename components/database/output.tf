output "tables" {
  value = {
    connections = {
      name       = aws_dynamodb_table.connections.name
      arn        = aws_dynamodb_table.connections.arn
      stream_arn = aws_dynamodb_table.connections.stream_arn
    }
  }
}
