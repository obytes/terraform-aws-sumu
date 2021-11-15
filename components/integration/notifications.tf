# Receives backend notifications requests
resource "aws_sns_topic" "notifications" {
  name = "${local.prefix}-notifications"
}

# Receives backend notifications requests
resource "aws_sqs_queue" "notifications" {
  name                        = "${local.prefix}-notifications"
  fifo_queue                  = false
  content_based_deduplication = false

  delay_seconds              = 0      # No delay
  max_message_size           = 262144 # 256 KiB
  receive_wait_time_seconds  = 0      # ReceiveMessage return immediately
  message_retention_seconds  = 345600 # 4 Days
  visibility_timeout_seconds = 120*6  # 12 minutes, 6 times the lambda timeout (AWS Recommendation)

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.notifications_dlq.arn
    maxReceiveCount     = 5 # Move failed messages to DLQ after 5 failures
  })

  tags = local.common_tags
}

resource "aws_sqs_queue" "notifications_dlq" {
  name = "${local.prefix}-notifications-dlq"
}
