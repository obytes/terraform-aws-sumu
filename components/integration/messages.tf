# Receives users messages from "publish" route
resource "aws_sns_topic" "messages" {
  name = "${local.prefix}-messages"
}

# Receives users messages from "send" route
resource "aws_sqs_queue" "messages" {
  name                        = "${local.prefix}-messages"
  fifo_queue                  = false
  content_based_deduplication = false

  delay_seconds              = 0      # No delay
  max_message_size           = 262144 # 256 KiB
  receive_wait_time_seconds  = 20     # Long Polling not Short Polling
  message_retention_seconds  = 345600 # 4 Days
  visibility_timeout_seconds = 120*6  # 12 minutes

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.messages_dlq.arn
    maxReceiveCount     = 5 # Move failed messages to DLQ after 5 failures
  })

  tags = local.common_tags
}

resource "aws_sqs_queue" "messages_dlq" {
  name = "${local.prefix}-messages-dlq"
}
