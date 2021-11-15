resource "aws_dynamodb_table" "connections" {
  name = "SumuConnections"

  ################
  # Billing
  ################
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 0
  write_capacity = 0

  ##################
  # Index/Sort Keys
  ##################
  hash_key  = "user_id"
  range_key = "connection_id"

  ##################
  # Attributes
  ##################
  # User (Partition Key)
  attribute {
    name = "user_id"
    type = "S"
  }

  # WS Connection ID (Sort Key)
  attribute {
    name = "connection_id"
    type = "S"
  }

  ttl {
    enabled        = true
    attribute_name = "delete_at"
  }

  stream_enabled   = true
  stream_view_type = "KEYS_ONLY"

  tags = {
    table_name = "SumuConnections"
  }
}
